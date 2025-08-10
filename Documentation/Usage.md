# Mercato Usage Guide

Mercato is a lightweight Swift Package for handling In-App Purchases using StoreKit 2. This guide covers the essential features and common usage patterns.

## Table of Contents
- [Installation](#installation)
- [Basic Setup](#basic-setup)
- [Product Management](#product-management)
- [Making Purchases](#making-purchases)
- [Transaction Handling](#transaction-handling)
- [Subscription Management](#subscription-management)
- [Advanced Features](#advanced-features)

## Installation

Add Mercato to your project using Swift Package Manager:

```swift
.package(url: "https://github.com/tikhop/Mercato.git", .upToNextMajor(from: "1.0.0"))
```

## Basic Setup

### Import Mercato

```swift
import Mercato
```

### ⚠️ Critical: Transaction Finishing

**IMPORTANT**: You MUST finish all transactions, otherwise users won't be able to make new purchases. Unfinished transactions block future purchases of the same product.

Two critical places where you must handle transaction finishing:

1. **On App Launch** - Process and finish any unfinished transactions
2. **After Each Purchase** - Finish the transaction after delivering content

### Start Transaction Listener and Process Unfinished Transactions

Start listening for transaction updates and process unfinished transactions as soon as your app launches. This is critical to prevent purchase blocking.

```swift
class AppDelegate {
    var transactionObserver: TransactionObserverHandler?
    
    func applicationDidFinishLaunching() {
        // CRITICAL: Process unfinished transactions first
        Task {
            await processUnfinishedTransactions()
        }
        
        // Start listening for new transaction updates
        transactionObserver = Mercato.listenForTransactionUpdates { transaction in
            await handleTransaction(transaction)
        }
    }
    
    // MUST BE CALLED ON APP LAUNCH
    func processUnfinishedTransactions() async {
        for await result in Mercato.unfinishedTransactions {
            do {
                let transaction = try result.payload
                
                // Validate and deliver content if needed
                if await validateAndDeliverContent(for: transaction) {
                    // CRITICAL: Finish the transaction
                    await transaction.finish()
                } else {
                    // Even if validation fails, you may need to finish
                    // to unblock future purchases
                    await transaction.finish()
                }
            } catch {
                print("Failed to process unfinished transaction: \(error)")
            }
        }
    }
    
    func handleTransaction(_ transaction: Transaction) async {
        // Check for revoked transactions
        if let revocationDate = transaction.revocationDate {
            // Remove access to the product
            removeAccess(for: transaction.productID)
            await transaction.finish()  // Finish even revoked transactions
            return
        }
        
        // Check for expired subscriptions
        if let expirationDate = transaction.expirationDate,
           expirationDate < Date() {
            // Subscription expired - remove access
            removeAccess(for: transaction.productID)
            await transaction.finish()  // Finish expired transactions
            return
        }
        
        // Check for upgraded subscriptions
        if transaction.isUpgraded {
            // Transaction has been upgraded to a higher service level
            await transaction.finish()  // Finish upgraded transactions
            return
        }
        
        // Grant access to the product
        grantAccess(for: transaction.productID)
        
        // CRITICAL: Always finish the transaction
        await transaction.finish()
    }
}
```

## Product Management

### Fetching Products

Retrieve product information from the App Store:

```swift
func loadProducts() async {
    do {
        let productIds: Set<String> = [
            "com.app.premium",
            "com.app.subscription.monthly",
            "com.app.coins.100"
        ]
        
        let products = try await Mercato.retrieveProducts(productIds: productIds)
        
        // Display products to the user
        for product in products {
            print("Product: \(product.displayName)")
            print("Price: \(product.displayPrice)")
            print("Description: \(product.description)")
        }
    } catch {
        print("Failed to load products: \(error)")
    }
}
```

### Check Purchase Status

Verify if a product has been purchased:

```swift
func checkPurchaseStatus(productId: String) async {
    do {
        let isPurchased = try await Mercato.isPurchased(productId)
        if isPurchased {
            print("Product \(productId) is purchased")
        }
    } catch {
        print("Failed to check purchase status: \(error)")
    }
}
```

## Making Purchases

### Simple Purchase

⚠️ **CRITICAL**: Always finish transactions after delivering content, otherwise users cannot purchase the same product again!

Purchase a product with manual transaction finishing (recommended):

```swift
func purchaseProduct(product: Product) async {
    do {
        let purchase = try await Mercato.purchase(
            product: product,
            finishAutomatically: false  // IMPORTANT: Manual finishing gives you control
        )
        
        // Validate and deliver content
        if await validatePurchase(purchase) {
            // Grant access first
            grantAccess(for: product.id)
            
            // CRITICAL: Always finish the transaction after delivering content
            // Unfinished transactions will block future purchases!
            await purchase.transaction?.finish()
        } else {
            // Even on validation failure, consider finishing to unblock purchases
            // You may want to log this for investigation
            await purchase.transaction?.finish()
        }
    } catch MercatoError.canceledByUser {
        print("User canceled the purchase")
    } catch MercatoError.purchaseIsPending {
        print("Purchase is pending (Ask to Buy)")
        // Transaction will appear in unfinished transactions later
    } catch {
        print("Purchase failed: \(error)")
    }
}
```

### ⚠️ Warning About Unfinished Transactions

If you don't finish transactions:
- Users **cannot** purchase the same product again
- The purchase button will appear to do nothing
- Users may think your app is broken
- Consumable purchases will be completely blocked

### Purchase with Options

Configure purchase with specific options:

```swift
func purchaseWithOptions(product: Product) async {
    do {
        // Using the builder pattern
        let options = Mercato.PurchaseOptionsBuilder()
            .setQuantity(2)
            .setAppAccountToken(UUID())
            .setSimulatesAskToBuyInSandbox(true)
            .build()
        
        let purchase = try await Mercato.purchase(
            product: product,
            options: options,
            finishAutomatically: false
        )
        
        // Handle the purchase
    } catch {
        print("Purchase failed: \(error)")
    }
}
```

### Purchase with Promotional Offer

Apply promotional offers for eligible subscriptions:

```swift
func purchaseWithOffer(product: Product, offer: PromotionalOffer) async {
    do {
        let purchase = try await Mercato.purchase(
            product: product,
            promotionalOffer: offer,
            finishAutomatically: false
        )
        
        // Handle the purchase
    } catch {
        print("Purchase failed: \(error)")
    }
}
```

## Transaction Handling

### Transaction Sequences

Mercato provides direct access to StoreKit 2's async sequences for real-time transaction monitoring:

```swift
// Monitor live transaction updates
Task {
    for await result in Mercato.updates {
        do {
            let transaction = try result.payload
            print("New transaction: \(transaction.productID)")
            
            // Process the transaction
            await processTransaction(transaction)
            
            // Finish when done
            await transaction.finish()
        } catch {
            print("Transaction verification failed: \(error)")
        }
    }
}

// Get all historical transactions
for await result in Mercato.allTransactions {
    let transaction = try result.payload
    print("Historical transaction: \(transaction.productID)")
}

// Current entitlements (active subscriptions & non-consumables)
for await result in Mercato.currentEntitlements {
    let transaction = try result.payload
    print("Active entitlement: \(transaction.productID)")
}

// Unfinished transactions (CRITICAL to process on launch)
for await result in Mercato.unfinishedTransactions {
    let transaction = try result.payload
    // Process and finish to unblock purchases
    await transaction.finish()
}
```

### Process Current Entitlements

Check active subscriptions and non-consumables on demand:

```swift
func checkCurrentEntitlements() async {
    for await result in Mercato.currentEntitlements {
        do {
            let transaction = try result.payload
            print("Active entitlement: \(transaction.productID)")
            
            // Update UI or user access based on entitlements
            grantAccess(for: transaction.productID)
        } catch {
            print("Failed to verify transaction: \(error)")
        }
    }
}

// Or check a specific product's entitlement
func checkSpecificEntitlement(productId: String) async {
    if let result = await Mercato.currentEntitlement(for: productId) {
        do {
            let transaction = try result.payload
            print("User has access to \(productId)")
            print("Expires: \(transaction.expirationDate ?? Date.distantFuture)")
        } catch {
            print("Transaction verification failed")
        }
    } else {
        print("No active entitlement for \(productId)")
    }
}
```

### Handle Unfinished Transactions

Process unfinished transactions on app launch:

```swift
func processUnfinishedTransactions() async {
    for await result in Mercato.unfinishedTransactions {
        do {
            let transaction = try result.payload
            
            // Validate and finish the transaction
            if await validateTransaction(transaction) {
                await transaction.finish()
            }
        } catch {
            print("Failed to process transaction: \(error)")
        }
    }
}
```

### Sync Purchases

Restore purchases when needed (rarely required with StoreKit 2):

```swift
func restorePurchases() async {
    do {
        // This prompts for authentication
        try await Mercato.syncPurchases()
        print("Purchases synced successfully")
    } catch {
        print("Failed to sync purchases: \(error)")
    }
}
```

## Subscription Management

### Check Intro Offer Eligibility

Determine if a user is eligible for an introductory offer:

```swift
func checkIntroOfferEligibility(productId: String) async {
    do {
        let isEligible = try await Mercato.isEligibleForIntroOffer(for: productId)
        if isEligible {
            print("User is eligible for intro offer")
        }
    } catch {
        print("Failed to check eligibility: \(error)")
    }
}
```

### Monitor Subscription States (Billing Retry & Grace Period)

Check and monitor important subscription states including billing retry and grace period:

```swift
// Check if subscription is in billing retry
func checkBillingRetry(productId: String) async {
    if await Mercato.isInBillingRetry(for: productId) {
        print("Subscription is in billing retry period")
        // Show payment update UI to user
    }
}

// Check if subscription is in grace period
func checkGracePeriod(productId: String) async {
    if await Mercato.isInGracePeriod(for: productId) {
        print("Subscription is in grace period")
        // User still has access but payment failed
    }
}

// Get the full renewal state
func checkRenewalState(productId: String) async {
    if let state = await Mercato.renewalState(for: productId) {
        switch state {
        case .subscribed:
            print("Active subscription")
        case .inBillingRetryPeriod:
            print("Payment failed, retrying")
            // Prompt user to update payment method
        case .inGracePeriod:
            print("In grace period, access continues")
            // Warn user about payment issue
        case .expired:
            print("Subscription expired")
            // Remove access
        case .revoked:
            print("Subscription was revoked")
            // Remove access immediately
        default:
            break
        }
    }
}

Use StoreKit 2's native subscription status streams for more detailed monitoring:

```swift
// Monitor all subscription status updates
func monitorSubscriptionStatusUpdates() {
    Task {
        for await status in Mercato.subscriptionStatusUpdates {
            print("Status update received")
            print("  State: \(status.state)")
            print("  Transaction: \(status.transaction)")
            print("  Renewal info: \(status.renewalInfo)")
            
            // Handle different states
            switch status.state {
            case .subscribed:
                print("  ✓ Active subscription")
            case .inBillingRetryPeriod:
                print("  ⚠️ Billing retry - payment failed")
            case .inGracePeriod:
                print("  ⚠️ Grace period - access continues")
            case .expired:
                print("  ✗ Subscription expired")
            case .revoked:
                print("  ✗ Subscription revoked")
            default:
                break
            }
        }
    }
}

// Monitor all subscription groups (iOS 17+)
@available(iOS 17.0, macOS 14.0, *)
func monitorAllSubscriptionGroups() {
    Task {
        for await (groupID, statuses) in Mercato.allSubscriptionStatuses {
            print("Subscription group: \(groupID)")
            
            // Handle multiple statuses (e.g., family sharing)
            for status in statuses {
                print("  Member status: \(status.state)")
                
                // Check expiration reason if expired
                if status.state == .expired,
                   let renewalInfo = try? status.renewalInfo?.payload {
                    switch renewalInfo.expirationReason {
                    case .autoRenewDisabled:
                        print("    User disabled auto-renewal")
                    case .billingError:
                        print("    Billing error occurred")
                    case .didNotConsentToPriceIncrease:
                        print("    User declined price increase")
                    case .productUnavailable:
                        print("    Product no longer available")
                    default:
                        break
                    }
                }
            }
        }
    }
}
```

### Product Extensions

Use helpful product extensions to display subscription information:

```swift
func displayProductInfo(product: Product) async {
    // Check subscription status
    if await product.hasActiveSubscription {
        print("User has active subscription")
    }
    
    // Display pricing
    print("Price: \(product.localizedPrice)")
    print("Display price: \(product.displayPrice)")  // StoreKit formatted
    
    // For subscriptions
    if let subscription = product.subscription {
        print("Period: \(product.localizedPeriod)")  // e.g., "1 month"
        print("Has trial: \(product.hasTrial)")
        print("Has pay-as-you-go: \(product.hasPayAsYouGoOffer)")
        
        // Price per day calculation
        print("Price per day: \(product.priceInDay)")  // Decimal value
        
        // Period in days
        print("Period in days: \(subscription.periodInDays)")
        
        // Check intro offer eligibility
        if await product.isEligibleForIntroOffer {
            if let introOffer = subscription.introductoryOffer {
                print("Intro price: \(introOffer.displayPrice)")
                print("Intro period: \(introOffer.localizedPeriod)")
                print("Intro duration: \(introOffer.localizedDuration)")
                print("Intro price/day: \(introOffer.priceInDay)")
            }
        }
    }
    
    // Get the locale used for pricing
    let priceLocale = product.priceLocale
    print("Price locale: \(priceLocale.identifier)")
}
```

### Manage Subscriptions (iOS only)

Show the manage subscriptions interface:

```swift
#if os(iOS)
@MainActor
func showSubscriptionManagement(in scene: UIWindowScene) async {
    do {
        try await Mercato.showManageSubscriptions(in: scene)
    } catch {
        print("Failed to show subscription management: \(error)")
    }
}
#endif
```

## Advanced Features

### Price and Period Formatters

Mercato includes built-in formatters for displaying prices and periods correctly:

```swift
// Price formatting with locale and currency
let price: Decimal = 9.99
let formattedPrice = price.formattedPrice(
    locale: .current,
    currencyCode: "USD",
    applyingRounding: false
)
// Result: "$9.99"

// Period formatting
let period = PeriodFormatter.format(
    unit: .month,
    numberOfUnits: 3
)
// Result: "3 months"

// The formatters are automatically used in Product extensions:
product.localizedPrice        // Already formatted price
product.localizedPeriod      // Already formatted period
```

### Currency Symbol Library

The library includes a comprehensive currency symbol mapper:

```swift
// Get native currency symbols
CurrencySymbolsLibrary.shared.symbol(for: "USD")  // "$"
CurrencySymbolsLibrary.shared.symbol(for: "EUR")  // "€"
CurrencySymbolsLibrary.shared.symbol(for: "GBP")  // "£"
CurrencySymbolsLibrary.shared.symbol(for: "JPY")  // "¥"
```

### Purchase Result Object

The `Purchase` struct provides convenient access to transaction details:

```swift
let purchase = try await Mercato.purchase(product: product)

// Access purchase details
print("Product ID: \(purchase.productId)")
print("Quantity: \(purchase.quantity)")
print("Transaction: \(purchase.transaction)")

// Check if manual finishing is needed
if purchase.needsFinishTransaction {
    // Deliver content first
    await deliverContent()
    
    // Then finish the transaction
    await purchase.finish()
}
```

### Direct Transaction Access

Get specific transactions when needed:

```swift
// Get the latest transaction for a product
if let result = await Mercato.latest(for: "com.app.premium") {
    let transaction = try result.payload
    print("Latest transaction date: \(transaction.purchaseDate)")
}

// Get current entitlement for a product
if let result = await Mercato.currentEntitlement(for: "com.app.subscription") {
    let transaction = try result.payload
    print("Subscription expires: \(transaction.expirationDate)")
}
```

### Refund Process (iOS/macOS)

Initiate a refund request:

```swift
#if os(iOS) || os(macOS)
func requestRefund(productId: String, in context: DisplayContext) async {
    do {
        try await Mercato.beginRefundProcess(for: productId, in: context)
        print("Refund process completed")
    } catch MercatoError.canceledByUser {
        print("User canceled refund request")
    } catch {
        print("Refund request failed: \(error)")
    }
}
#endif
```

### Transaction Verification

Access raw transaction data for server verification:

```swift
func verifyTransaction(_ transaction: Transaction) async -> Bool {
    // Get the JWS representation for server verification
    let jwsRepresentation = transaction.jsonRepresentation
    
    // Send to your server for verification
    // return await yourServer.verify(jwsRepresentation)
    
    return true
}
```

### Error Handling

Handle common purchase errors:

```swift
func handlePurchaseError(_ error: MercatoError) {
    switch error {
    case .canceledByUser:
        // User canceled - no action needed
        break
        
    case .purchaseIsPending:
        // Ask to Buy - will complete later
        showPendingMessage()
        
    case .purchase(let purchaseError):
        // Handle specific purchase errors
        showErrorMessage("Purchase failed: \(purchaseError)")
        
    case .failedVerification(_, let verificationError):
        // Transaction verification failed
        logVerificationError(verificationError)
        
    case .productUnavailable:
        // Product not found
        showErrorMessage("Product not available")
        
    default:
        showErrorMessage("An error occurred: \(error)")
    }
}
```

## Best Practices

1. **⚠️ ALWAYS finish transactions**: This is the #1 cause of purchase issues. Unfinished transactions block future purchases. Finish transactions:
   - On app launch (process `Mercato.unfinishedTransactions`)
   - After every successful purchase
   - Even for failed validations (to unblock future purchases)

2. **Process unfinished transactions on launch**: Always check and finish unfinished transactions when your app starts to prevent blocking issues.

3. **Start transaction listeners early**: Set up transaction observers in your app delegate or initial view controller to catch all transactions.

4. **Handle pending transactions**: Implement proper handling for Ask to Buy and other pending states.

5. **Validate on your server**: For sensitive purchases, validate transactions on your server before granting access.

6. **Deliver content before finishing**: Grant user access to content BEFORE calling `finish()` on the transaction.

7. **Cache product information**: Store product details locally to improve performance and reduce App Store API calls.

8. **Test in sandbox**: Always test purchases in the sandbox environment before releasing to production.

9. **Handle all transaction states**: Check for revocations, expirations, and upgrades when processing transactions.

10. **Provide restore functionality**: Although rarely needed with StoreKit 2, provide a way for users to sync purchases if they believe something is missing.

## Testing

Use StoreKit Configuration files for local testing:

1. Create a `.storekit` configuration file in Xcode
2. Add test products matching your App Store Connect configuration
3. Enable the StoreKit configuration in your scheme
4. Test various scenarios including successful purchases, cancellations, and Ask to Buy

## Troubleshooting

Common issues and solutions:

- **⚠️ User can't purchase same product again**: This is caused by unfinished transactions. Solution:
  - Check for `Mercato.unfinishedTransactions` on app launch
  - Always call `transaction.finish()` after purchases
  - Even failed validations should be finished to unblock purchases

- **Purchase button does nothing**: Usually caused by unfinished transactions blocking new purchases

- **Products not loading**: Ensure product IDs match App Store Connect exactly

- **Purchases failing**: Check sandbox account is signed in for testing

- **Transactions not finishing**: Ensure you call `finish()` after delivering content

- **Missing entitlements**: Use `Mercato.syncPurchases()` as a last resort

- **"Cannot connect to iTunes Store"**: Check network connection and StoreKit configuration

For more examples and detailed API documentation, refer to the project's test files and inline documentation.
