import Foundation
import StoreKit

//typealias Transaction = StoreKit.Transaction
//typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
//typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState
typealias TransactionUpdate = ((Transaction) -> ())

public class Mercato {
	
	private var purchaseController = PurchaseController()
	private var productService = ProductService()
	
	private var updateListenerTask: Task<(), Never>? = nil
	
    public init()
	{
    }
	
	func listenForTransactions(atomically: Bool = true, updateBlock: TransactionUpdate?)
	{
		let task = Task.detached {
			//Iterate through any transactions which didn't come from a direct call to `purchase()`.
			for await result in Transaction.updates {
				do {
					let transaction = try checkVerified(result)
					
					if atomically
					{
						await transaction.finish()
					}
					
					updateBlock?(transaction)
				} catch {
					print("Transaction failed verification")
				}
			}
		}
		
		self.updateListenerTask = task
	}
	
	//TODO: throw an error if productId are invalid
	//TODO: move into product service
	@MainActor
	public func retrieveProducts(productIds: Set<String>) async throws -> [Product]
	{
		try await productService.retrieveProducts(productIds: productIds)
	}
	
	@discardableResult
	public func purchase(product: Product, quantity: Int = 1, atomically: Bool = true, appAccountToken: UUID? = nil, simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase
	{
		try await purchaseController.makePurchase(product: product, quantity: quantity, atomically: atomically, appAccountToken: appAccountToken, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
	}
	
	deinit {
		updateListenerTask?.cancel()
	}
}

func checkVerified<T>(_ result: VerificationResult<T>) throws -> T
{
	switch result
	{
	case .verified(let safe):
		return safe
	case .unverified:
		throw MercatoError.failedVerification
	}
}

