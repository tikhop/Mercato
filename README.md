<p align="center">
  <img height="160" src="https://github.com/tikhop/Mercato/blob/master/www/logo.png" />
</p>

# Mercato

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Language](https://img.shields.io/badge/swift-5.5-orange.svg)](https://developer.apple.com/swift)

Mercato is a lightweight In-App Purchases (StoreKit 2) library for iOS, tvOS, watchOS, macOS, and Mac Catalyst.

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

### CocoaPods

In progress...

Then, run the following command:

```bash
$ pod install
```

In any swift file you'd like to use Mercato, import the framework with `import Mercato`.

### Requirements

- iOS 15.0 / OSX 12.0 / watchOS 8.0
- Swift 5.5

Usage
-------------

## Essential Reading
* [Apple - Meet StoreKit 2](https://developer.apple.com/videos/play/wwdc2021/10114/)
* [Apple - In-App Purchase](https://developer.apple.com/documentation/storekit/in-app_purchase)
* [WWDC by Sundell - Working With In-App Purchases in StoreKit 2](https://wwdcbysundell.com/2021/working-with-in-app-purchases-in-storekit2/)
* [WWDC by Sundell - Working With In-App Purchases in StoreKit 2](https://wwdcbysundell.com/2021/working-with-in-app-purchases-in-storekit2/)

## License

Mercato is released under an MIT license. See [LICENSE](https://github.com/tikhop/TPInAppReceipt/blob/master/LICENSE) for more information.
