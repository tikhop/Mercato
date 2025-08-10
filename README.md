<p align="center">
  <img height="160" src="https://github.com/tikhop/Mercato/blob/master/www/logo.png" />
</p>

# Mercato

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Swift](https://img.shields.io/badge/swift-5.10-orange.svg)](https://developer.apple.com/swift)

StoreKit 2 wrapper for In-App Purchases.

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/tikhop/Mercato.git", .upToNextMajor(from: "1.0.0"))
```

## Requirements

- Swift 5.10+
- iOS 15.4+ / macOS 12.3+ / tvOS 17.0+ / watchOS 10.0+ / visionOS 1.0+

## Usage

### Basic Purchase

```swift
import Mercato

// Fetch products
let products = try await Mercato.retrieveProducts(
    productIds: ["com.app.premium", "com.app.subscription"]
)

// Purchase
let purchase = try await Mercato.purchase(
    product: product,
    finishAutomatically: false
)

// Deliver content and finish
grantAccess(for: purchase.productId)
await purchase.finish()
```

### Transaction Monitoring

```swift
// Current entitlements
for await result in Mercato.currentEntitlements {
    let transaction = try result.payload
    // Active subscriptions and non-consumables
}

// Live updates
for await result in Mercato.updates {
    let transaction = try result.payload
    await processTransaction(transaction)
    await transaction.finish()
}
```

### Subscription Features

```swift
// Check eligibility
if await product.isEligibleForIntroOffer {
    // Show intro pricing
}

// Product info
product.localizedPrice        // "$9.99"
product.localizedPeriod      // "1 month"
product.hasTrial             // true/false
product.priceInDay           // 0.33
```

### Purchase Options

```swift
let options = Mercato.PurchaseOptionsBuilder()
    .setQuantity(3)
    .setPromotionalOffer(offer)
    .setAppAccountToken(token)
    .build()

let purchase = try await Mercato.purchase(
    product: product,
    options: options,
    finishAutomatically: false
)
```


### Error Handling

```swift
do {
    let purchase = try await Mercato.purchase(product: product)
} catch MercatoError.canceledByUser {
    // User canceled
} catch MercatoError.purchaseIsPending {
    // Ask to Buy
} catch MercatoError.productUnavailable {
    // Product not found
}
```

### Utilities

```swift
// Check purchase status
let isPurchased = try await Mercato.isPurchased("com.app.premium")

// Get latest transaction
if let result = await Mercato.latest(for: productId) {
    let transaction = try result.payload
}

// Sync purchases (rarely needed)
try await Mercato.syncPurchases()
```

## Documentation

See [Usage.md](Documentation/Usage.md) for complete documentation.

## Contributing

Contributions are welcome. Please feel free to submit a Pull Request.

## License

MIT. See [LICENSE](LICENSE) for details.