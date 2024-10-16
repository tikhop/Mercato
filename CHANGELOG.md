CHANGELOG
=========

Mercato 1.0.0
---------

### Added

### Updated

### Fixed

Mercato 0.0.1
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

