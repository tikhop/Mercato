<p align="center">
  <img height="160" src="https://github.com/tikhop/Mercato/blob/master/www/logo.png" />
</p>

# Mercato

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Language](https://img.shields.io/badge/swift-5.5-orange.svg)](https://developer.apple.com/swift)

Mercato is a lightweight In-App Purchases (StoreKit 2) library.

Installation
------------

### Swift Package Manager

To integrate using Apple's Swift package manager, add the following as a dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/tikhop/Mercato.git", .upToNextMajor(from: "0.0.1"))
```

Then, specify `"Mercato"` as a dependency of the Target in which you wish to use Mercato.

Lastly, run the following command:
```swift
swift package update
```

### Requirements

- iOS 15.0 / OSX 12.0 / watchOS 8.0
- Swift 5.5

Usage
-------------

### Listen for transaction updates

Start transaction update listener as soon as your app launches so you don't miss a single transaction. This is important, for example, to handle transactions that may have occured after `purchase` returns, like an adult approving a child's purchase request or a purchase made on another device.

> If your app has unfinished transactions, you receive them immediately after the app launches

```swift
var observer: TransactionObserverHandler!

observer = Mercato.listenForTransactionUpdates { transaction in
    if let revocationDate = transaction.revocationDate {
        // Remove access to the product identified by transaction.productID.
        // Transaction.revocationReason provides details about
        // the revoked transaction.
        <#...#>
    } else if let expirationDate = transaction.expirationDate,
        expirationDate < Date() {
        // Do nothing, this subscription is expired.
        return
    } else if transaction.isUpgraded {
        // Do nothing, there is an active transaction
        // for a higher level of service.
        return
    } else {
        // Provide access to the product identified by
        // transaction.productID.
        <#...#>
    }
}

Mercato.removeListenerForTransactionUpdates(observer)

```

### Listen for current entitlements

Returns all transactions for products the user is currently entitled to.\
i.e. all currently-subscribed transactions, and all purchased (and not refunded) non-consumables

```swift
Mercato.listenForCurrentEntitlement(onlyRenewable: true) { transaction in
    print("Current Entitlement: \(transaction)")
}


// Remove listener for current entitlement
let observer = ...
Mercato.removeListenerCurrentEntitlement(observer)

```

### Listen for all transactions

```swift
Mercato.listenForCurrentEntitlement(onlyRenewable: true) { transaction in
    print("Current Entitlement: \(transaction)")
}


// Remove listener for current entitlement
let observer = ...
Mercato.removeListenerCurrentEntitlement(observer)

```

### Fetch products

```swift
do
{
    let productIds: Set<String> = ["com.test.product.1", "com.test.product.2", "com.test.product.3"]
    let products = try await Mercato.retrieveProducts(productIds: productIds)
	
    //Show products to the user
}catch{
    //Handle errors
}
```

### Purchase a product 

```swift
try await Mercato.purchase(product: product, quantity: 1, finishAutomatically: false, appAccountToken: nil, simulatesAskToBuyInSandbox: false)
```

### Offering in-app refunds

```swift
try await Mercato.beginRefundProcess(for: product, in: windowScene)
```

### Restore completed transactions

 In general users won't need to restore completed transactions when your app is reinstalled or downloaded on a new device. Everything should automatically be fetched by StoreKit and stay up to date. In the rare case that a user thinks they should have a transaction but you don't see it, you have to provide UI in your app that allows users to initiate the sync. It should be very rare that a user needs to initiate a sync manually. Automatic synchronization should cover the majority of cases.
  
```swift
try await Mercato.restorePurchases()
```

## Essential Reading

* [Apple - Meet StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/)
* [Apple - In-App Purchase](https://developer.apple.com/documentation/storekit/in-app_purchase)
* [WWDC by Sundell - Working With In-App Purchases in StoreKit 2](https://wwdcbysundell.com/2021/working-with-in-app-purchases-in-storekit2/)

## License

Mercato is released under an MIT license. See [LICENSE](https://github.com/tikhop/Mercato/blob/master/LICENSE) for more information.
