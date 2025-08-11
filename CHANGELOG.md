CHANGELOG
=========

Mercato 1.0.1
---------

### Fixed
* Compilation issue on WatchOS
* Example iOS application issue 

Mercato 1.0.0
---------

### Added
* Subscription state monitoring for billing retry and grace period (addresses [#6](https://github.com/tikhop/Mercato/issues/6))
  - `isInBillingRetry(for:)` - Check if subscription is in billing retry state
  - `isInGracePeriod(for:)` - Check if subscription is in grace period
  - `renewalState(for:)` - Get current renewal state for a subscription
  - `subscriptionStatusUpdates` - Direct access to StoreKit 2's subscription status update stream
  - `allSubscriptionStatuses` - Stream of all subscription group statuses (iOS 17+)
* Comprehensive product extension methods for subscription details (localizedPrice, localizedPeriod, hasTrial, priceInDay)
* PurchaseOptionsBuilder for fluent configuration of purchase options
* PromotionalOffer model for handling subscription offers
* ProductService with better caching for product fetching
* PriceFormatter and PeriodFormatter utilities for localized formatting
* CurrencySymbolsLibrary for comprehensive currency symbol support
* Example iOS application demonstrating usage
* Detailed usage documentation in Documentation/Usage.md
* Support for visionOS platform

### Updated
* Migrated to Swift 6.0 tools version while maintaining Swift 5.10 compatibility
* Reorganized code structure 
* Enhanced error handling with more specific MercatoError cases
* Simplified purchase API with automatic option building
* Enhanced README with comprehensive usage examples

Mercato 0.0.1-0.0.3
---------

* Listen for transaction updates. If your app has unfinished transactions, you receive them immediately after the app launches
  ```swift
  Mercato.listenForTransactions(finishAutomatically: false) { transaction in
    //Deliver content to the user.
			
    //Finish transaction
    await transaction.finish()
  }
  ```

* Fetch products for the given set of product's ids
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

* Purchase a product 
  ```swift
  try await Mercato.purchase(product: product, quantity: 1, finishAutomatically: false, appAccountToken: nil, simulatesAskToBuyInSandbox: false)
  ```

* Offering in-app refunds

  ```swift
  try await Mercato.beginRefundProcess(for: product, in: windowScene)
  ```

* Restore completed transactions

  ```swift
  try await Mercato.restorePurchases()
  ```

