import Foundation
import StoreKit

public typealias TransactionUpdate = ((Transaction) -> ())

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
	public func retrieveProducts(productIds: Set<String>) async throws -> [Product]
	{
		try await productService.retrieveProducts(productIds: productIds)
	}
	
	@discardableResult
	public func purchase(product: Product, quantity: Int = 1, atomically: Bool = true, appAccountToken: UUID? = nil, simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase
	{
		try await purchaseController.makePurchase(product: product, quantity: quantity, atomically: atomically, appAccountToken: appAccountToken, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
	}
	
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	func beginRefundProcess(for productID: String, in scene: UIWindowScene) async -> Result<String, Error>
	{
		guard case .verified(let transaction) = await Transaction.latest(for: productID) else { return .failure(MercatoError.failedVerification) }
		
		do {
			let status = try await transaction.beginRefundRequest(in: scene)
			
			switch status
			{
			case .userCancelled:
				return .failure(MercatoError.userCancelledRefundProcess)
			case .success:
				return .success(productID)
			@unknown default:
				return .failure(MercatoError.genericError)
			}
		} catch {
			//TODO: return a specific error
			return .failure(error)
		}
	}
	
	deinit {
		updateListenerTask?.cancel()
	}
}

extension Mercato
{
	fileprivate static let shared: Mercato = .init()
	
	public static func listenForTransactions(atomically: Bool = true, updateBlock: TransactionUpdate?)
	{
		shared.listenForTransactions(atomically: atomically, updateBlock: updateBlock)
	}
	
	public static func retrieveProducts(productIds: Set<String>) async throws -> [Product]
	{
		try await shared.retrieveProducts(productIds: productIds)
	}
	
	public static func purchase(product: Product,
								quantity: Int = 1,
								atomically: Bool = true,
								appAccountToken: UUID? = nil,
								simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase
	{
		try await shared.purchase(product: product,
										 quantity: quantity,
										 atomically: atomically,
										 appAccountToken: appAccountToken,
										 simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
	}
	
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	public static func beginRefundProcess(for product: Product, in scene: UIWindowScene) async -> Result<String, Error>
	{
		await shared.beginRefundProcess(for: product.id, in: scene)
	}
	
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	public static func beginRefundProcess(for productID: String, in scene: UIWindowScene) async -> Result<String, Error>
	{
		await shared.beginRefundProcess(for: productID, in: scene)
	}
	
	public static func restorePurchases() async throws
	{
		try await AppStore.sync()
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

