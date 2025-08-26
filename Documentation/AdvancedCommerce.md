# Advanced Commerce API Guide

Use the Advanced Commerce API to more easily support exceptionally large content catalogs, creator experiences, and subscriptions with optional add-ons offered within your apps.
> This feature is available on iOS 18.4+, macOS 15.4+, tvOS 18.4+, watchOS 11.4+, and visionOS 2.4+.

## Overview

Advanced Commerce allows you to make certain API requests through StoreKit in your app, while other requests are made directly from your server. Both approaches use signatures generated on your server for authorization.


## Installation

The Advanced Commerce functionality is provided in a separate module:

```swift
import AdvancedCommerceMercato
```

## Available Methods

The `AdvancedCommerceMercato` class provides the following methods:

### Product Retrieval
- **`retrieveProducts(productIds:)`** - Retrieve Advanced Commerce products by their IDs
  ```swift
  let products = try await AdvancedCommerceMercato.shared.retrieveProducts(
      productIds: ["com.app.premium", "com.app.basic"]
  )
  ```

### Purchase Methods
- **`purchase(productId:compactJWS:confirmIn:options:)`** - Purchase using Advanced Commerce with JWS (non-watchOS)
  ```swift
  let purchase = try await AdvancedCommerceMercato.purchase(
      productId: "com.app.premium",
      compactJWS: signedJWS,
      confirmIn: viewController, // UIViewController on iOS, NSWindow on macOS
      options: []
  )
  ```

- **`purchase(productId:compactJWS:options:)`** - Purchase using Advanced Commerce with JWS (watchOS only)
  ```swift
  let purchase = try await AdvancedCommerceMercato.purchase(
      productId: "com.app.premium",
      compactJWS: signedJWS,
      options: []
  )
  ```

### Transaction Management
- **`allTransactions(for:)`** - Get all transactions for a product ID
- **`currentEntitlements(for:)`** - Get current entitlements for a product ID
- **`latestTransaction(for:)`** - Get the latest transaction for a product ID

All static methods are also available as instance methods on `AdvancedCommerceMercato.shared`.

## Sending Advanced Commerce API requests from your app

The following Advanced Commerce API requests are available through StoreKit:

- **OneTimeChargeCreateRequest** - Create one-time purchases with custom pricing
- **SubscriptionCreateRequest** - Create subscriptions with flexible billing terms
- **SubscriptionModifyInAppRequest** - Modify existing subscriptions
- **SubscriptionReactivateInAppRequest** - Reactivate expired subscriptions

### 1. Create the base64-encoded request data in your app

Place the Advanced Commerce request data in a UTF-8 JSON string and base64-encode the request.
For example, the following JSON represents a `OneTimeChargeCreateRequest` for the purchase of a one-time charge product:

```json
{
    "operation": "CREATE_ONE_TIME_CHARGE",
    "version": "1",                     
    "requestInfo": {
        "requestReferenceId": "f55df048-4cd8-4261-b404-b6f813ff70e5"
    },
    "currency": "USD",
    "taxCode": "C003-00-2", 
    "storefront": "USA",
    "item": {
        "SKU": "BOOK_SHERLOCK_HOMLES",
        "displayName": "Sherlock Holmes", 
        "description": "The Sherlock Holmes, 5th Edition",
        "price": 4990
    }
}
```

#### Example: 
To create this object use OneTimeChargeCreateRequest model or any other request objects:
```swift
func encodeRequestToBase64(_ request: Codable) throws -> String {
   let encoder = JSONEncoder()
   encoder.outputFormatting = .prettyPrinted
   
   let jsonData = try encoder.encode(request)
   return jsonData.base64EncodedString()
}

let request = OneTimeChargeCreateRequest(...)
let base64encodedRequest = encodeRequestToBase64(request)
```

Base64-encode this JSON to create your request data.

### 2. Server-Side: Generate the JWS using your request data

Follow the [signing instructions for Advanced Commerce API](https://developer.apple.com/documentation/storekit/generating-jws-to-sign-app-store-requests) in-app requests in Generating JWS to sign App Store requests. The Advanced Commerce API requires a custom claim, request. Provide the base64-encoded request data from the previous step as the value of the request claim in the JWS payload.
The result after following the instructions is a JWS compact serialization.

### 3. Server-Side: Wrap the JWS and convert it into data

Wrap the JWS to create a signatureInfo JSON string that contains a token key. You can complete this step on your server or in your app. Create the signatureInfo JSON string as shown below:

```json
{
    "signatureInfo": {
        "token": "<your JWS compact serialization>"
    }
}
```

- Set the value of the token key to your JWS compact serialization.
- Next, convert the signatureInfo JSON string into a Data buffer, as shown below:

```
// Could be different api for different languages but the idea is the same
let jsonString ="<# your signatureInfo UTF-8 JSON string>"
let advancedCommerceRequestData = Data(jsonString.utf8)
```

The result is the Advanced Commerce request data object, referred to as `advancedCommerceRequestData in the code snippets.
Securely send the advancedCommerceRequestData to your app.

### 4. App-Side: Call the StoreKit purchase API using the signed request data

To complete the Advanced Commerce request in the app, call a AdvancedCommerceMercato purchase method and provide product id and the signed request.

```swift
import AdvancedCommerceMercato

let purchase = try await AdvancedCommerceMercato.purchase(
    productId: "com.app.premium",
    advancedCommerceData: signedJWS
)

```

## Request Models

Mercato provides Swift models for all supported request types:

### Request Validation

All Advanced Commerce request models conform to the `Validatable` protocol and include a `validate()` method that checks for valid parameters before sending to your server. This helps catch errors early in the development process:

```swift
do {
    let request = OneTimeChargeCreateRequest(
        currency: "USD",
        item: OneTimeChargeItem(
            sku: "BOOK_SHERLOCK_HOLMES",
            displayName: "Sherlock Holmes",
            description: "The Sherlock Holmes, 5th Edition",
            price: 4990
        ),
        requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
        taxCode: "C003-00-2",
        storefront: "USA"
    )
    
    // Validate the request before sending
    try request.validate()
    
    // If validation passes, encode and send to server
    let base64Request = try encodeRequestToBase64(request)
    // ... send to server
    
} catch {
    print("Validation failed: \(error)")
    // Handle validation errors
}
```

The validation checks include:
- **Currency codes** - Validates ISO 4217 currency codes
- **Tax codes** - Ensures proper tax code format
- **Storefront codes** - Validates country/region codes
- **Transaction IDs** - Checks transaction ID format
- **Required fields** - Ensures all required fields are present
- **Nested objects** - Validates all nested items and descriptors

It's recommended to always validate requests before sending them to your server to ensure data integrity and prevent server-side errors.

### OneTimeChargeCreateRequest

```swift
let request = OneTimeChargeCreateRequest(
    currency: "USD",
    item: OneTimeChargeItem(
        sku: "BOOK_SHERLOCK_HOLMES",
        displayName: "Sherlock Holmes",
        description: "The Sherlock Holmes, 5th Edition",
        price: 4990
    ),
    requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
    taxCode: "C003-00-2",
    storefront: "USA"
)
```

### SubscriptionCreateRequest

```swift
let request = SubscriptionCreateRequest(
    currency: "USD",
    descriptors: Descriptors(
        displayName: "Premium Subscription",
        description: "Access to all premium features"
    ),
    items: [
        SubscriptionCreateItem(
            sku: "PREMIUM_MONTHLY",
            displayName: "Premium Monthly",
            description: "Monthly subscription",
            price: 999
        )
    ],
    period: Period(value: 1, unit: .month),
    previousTransactionId: nil, // Optional: for upgrades/downgrades
    requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
    storefront: "USA",
    taxCode: "C003-00-2"
)
```

### SubscriptionModifyInAppRequest

```swift
let request = SubscriptionModifyInAppRequest(
    requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
    addItems: [
        SubscriptionModifyAddItem(
            sku: "PREMIUM_ADDON",
            displayName: "Premium Add-on",
            description: "Additional features",
            price: 299
        )
    ],
    changeItems: nil, // Optional: items to modify
    removeItems: nil, // Optional: items to remove
    currency: "USD",
    descriptors: nil, // Optional: update subscription descriptors
    periodChange: nil, // Optional: change billing period
    retainBillingCycle: true,
    storefront: "USA",
    taxCode: "C003-00-2",
    transactionId: "1234567890" // Required: existing transaction ID
)

// Alternative: Using builder pattern
let request = SubscriptionModifyInAppRequest(
    requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
    retainBillingCycle: true,
    transactionId: "1234567890"
)
.addAddItem(
    SubscriptionModifyAddItem(
        sku: "PREMIUM_ADDON",
        displayName: "Premium Add-on",
        description: "Additional features",
        price: 299
    )
)
.currency("USD")
.storefront("USA")
.taxCode("C003-00-2")
```

### SubscriptionReactivateInAppRequest

```swift
let request = SubscriptionReactivateInAppRequest(
    requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
    items: [
        SubscriptionReactivateItem(
            sku: "PREMIUM_MONTHLY",
            displayName: "Premium Monthly",
            description: "Monthly subscription",
            price: 999
        )
    ],
    transactionId: "1234567890", // Required: previous transaction ID
    storefront: "USA"
)

// Alternative: Using builder pattern
let request = SubscriptionReactivateInAppRequest(
    requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
    transactionId: "1234567890"
)
.addItem(
    SubscriptionReactivateItem(
        sku: "PREMIUM_MONTHLY",
        displayName: "Premium Monthly",
        description: "Monthly subscription",
        price: 999
    )
)
.storefront("USA")
```

## Transaction Management

Advanced Commerce purchases integrate with Mercato's transaction monitoring:

```swift
// Get all transactions for a product
let transactions = await AdvancedCommerceMercato.allTransactions(for: productId)

// Get current entitlements
let entitlements = await AdvancedCommerceMercato.currentEntitlements(for: productId)

// Get latest transaction
let latest = await AdvancedCommerceMercato.latestTransaction(for: productId)
```

## Error Handling

Advanced Commerce operations throw `MercatoError`:

```swift
do {
    let purchase = try await AdvancedCommerceMercato.purchase(
        productId: productId,
        compactJWS: jws,
        confirmIn: view
    )
} catch MercatoError.productNotFound {
    // Product ID not found
} catch MercatoError.canceledByUser {
    // User canceled the purchase
} catch MercatoError.purchaseIsPending {
    // Purchase requires approval (Ask to Buy)
} catch {
    // Handle other errors
}
```

## Complete Examples

### Example 1: StoreKit Purchase with Advanced Commerce Data

This approach uses StoreKit's standard purchase flow with server-provided Advanced Commerce data:

```swift
import AdvancedCommerceMercato

class PurchaseManager {
    func encodeRequestToBase64(_ request: Codable) throws -> String {
       let encoder = JSONEncoder()
       encoder.outputFormatting = .prettyPrinted
       
       let jsonData = try encoder.encode(request)
       return jsonData.base64EncodedString()
    }

    func purchaseWithAdvancedCommerce(productId: String) async throws {
        // 0. Build request data
        let request = OneTimeChargeCreateRequest(
            currency: "USD",
            item: OneTimeChargeItem(
                sku: "BOOK_SHERLOCK_HOLMES",
                displayName: "Sherlock Holmes",
                description: "The Sherlock Holmes, 5th Edition",
                price: 4990
            ),
            requestInfo: RequestInfo(requestReferenceId: UUID().uuidString),
            taxCode: "C003-00-2",
            storefront: "USA"
        )
        let base64encodedRequest = encodeRequestToBase64(request)
        
        // 1. Get Advanced Commerce data from your server
        let advancedCommerceData = try await fetchAdvancedCommerceDataFromServer(
            for: base64encodedRequest
        )
        
        // 2. Make the purchase through StoreKit
        let result = try await AdvancedCommerceMercato.purchase(
            productId: productId,
            advancedCommerceData: advancedCommerceData
        )
        
        // 3. Handle the result
        switch result {
        case .success(let verification):
            let transaction = try verification.payload
            
            // Deliver the content
            await deliverContent(for: transaction.productID)
            
            // Finish the transaction
            await transaction.finish()
            
        case .userCancelled:
            print("Purchase cancelled by user")
            
        case .pending:
            print("Purchase pending approval")
            
        @unknown default:
            print("Unknown purchase result")
        }
    }
}
```

### Example 2: Direct Advanced Commerce Purchase

This approach uses Advanced Commerce products with full control over the purchase flow:

```swift
import AdvancedCommerceMercato

class AdvancedPurchaseManager {
    func purchaseAdvancedCommerceProduct(productId: String) async throws {
        // 1. Get signed JWS from your server
        let compactJWS = try await fetchSignedJWSFromServer(
            for: productId,
            operation: .createOneTimeCharge
        )
        
        // 2. Make the Advanced Commerce purchase
        #if os(watchOS)
        let purchase = try await AdvancedCommerceMercato.purchase(
            productId: productId,
            compactJWS: compactJWS,
            options: []
        )
        #else
        let purchase = try await AdvancedCommerceMercato.purchase(
            productId: productId,
            compactJWS: compactJWS,
            confirmIn: getCurrentUIContext(),
            options: []
        )
        #endif
        
        // 3. Handle the purchase
        await handlePurchase(purchase)
    }
    
    private func handlePurchase(_ purchase: AdvancedCommercePurchase) async {
        // Deliver content
        await deliverContent(for: purchase.productId)
        
        // Check if transaction needs finishing
        if purchase.needsFinishTransaction {
            await purchase.finish()
        }
        
        // Verify the purchase with your server
        await verifyWithServer(transaction: purchase.transaction)
    }
    
    #if !os(watchOS)
    private func getCurrentUIContext() -> PurchaseUIContext {
        #if os(iOS)
        // Return current UIViewController
        return UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        #elseif os(macOS)
        // Return current NSWindow
        return NSApplication.shared.mainWindow ?? NSWindow()
        #endif
    }
    #endif
}
```

### Example 3: Complete Transaction Management

```swift
import AdvancedCommerceMercato

class TransactionManager {
    func checkUserEntitlements() async {
        let productIds = ["com.app.premium", "com.app.basic"]
        
        for productId in productIds {
            // Check current entitlements
            if let entitlements = await AdvancedCommerceMercato.currentEntitlements(for: productId) {
                for await transaction in entitlements {
                    print("Active entitlement: \(transaction.productID)")
                    // Update UI based on active subscriptions
                }
            }
            
            // Get latest transaction
            if let latest = await AdvancedCommerceMercato.latestTransaction(for: productId) {
                switch latest {
                case .verified(let transaction):
                    print("Latest verified transaction: \(transaction.id)")
                case .unverified(let transaction, let error):
                    print("Unverified transaction: \(error)")
                }
            }
        }
    }
    
    func getAllTransactionHistory(for productId: String) async {
        guard let transactions = await AdvancedCommerceMercato.allTransactions(for: productId) else {
            return
        }
        
        for await transaction in transactions {
            print("Transaction: \(transaction.id), Date: \(transaction.purchaseDate)")
        }
    }
}
```

## Further Resources

- [Apple's Advanced Commerce API Documentation](https://developer.apple.com/documentation/advancedcommerceapi)
- [Sending Advanced Commerce API requests from your app](https://developer.apple.com/documentation/storekit/sending-advanced-commerce-api-requests-from-your-app)
- [Generating JWS for App Store Requests](https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
