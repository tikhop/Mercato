import Foundation
import StoreKit

public final class Mercato {
	
	private var purchaseController = PurchaseController()
	private var productService = ProductService()
	
	private var updateListenerTask: Task<(), Never>? = nil
	
    private var transactionUpdateListeners: [TransactionObserverHandler: TransactionObserver] = [:]
		
	func listenForTransactionUpdates(finishAutomatically: Bool = true, updateBlock: TransactionUpdate?) -> TransactionObserverHandler
	{
        let handler = TransactionObserverHandler()
        let observer = TransactionObserver(handler: updateBlock)
        transactionUpdateListeners[handler] = observer
        return handler
	}
	
    func removeListenerForTransactionUpdates(_ handler: TransactionObserverHandler) {
        let observer = transactionUpdateListeners[handler]
        observer?.stop()
        transactionUpdateListeners[handler] = nil
    }
    
	//TODO: throw an error if productId are invalid
	public func retrieveProducts(productIds: Set<String>) async throws -> [Product]
	{
		try await productService.retrieveProducts(productIds: productIds)
	}
	
	@discardableResult
	public func purchase(product: Product, quantity: Int = 1, finishAutomatically: Bool = true, appAccountToken: UUID? = nil, simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase
	{
		try await purchaseController.makePurchase(product: product, quantity: quantity, finishAutomatically: finishAutomatically, appAccountToken: appAccountToken, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
	}
	
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	func beginRefundProcess(for productID: String, in scene: UIWindowScene) async throws
	{
		guard case .verified(let transaction) = await Transaction.latest(for: productID) else { throw MercatoError.failedVerification }
		
		do {
			let status = try await transaction.beginRefundRequest(in: scene)
			
			switch status
			{
			case .userCancelled:
				throw MercatoError.userCancelledRefundProcess
			case .success:
				break
			@unknown default:
				throw MercatoError.genericError
			}
		} catch {
			//TODO: return a specific error
			throw error
		}
	}
	
	deinit {
		updateListenerTask?.cancel()
	}
}

extension Mercato
{
	fileprivate static let shared: Mercato = .init()
	
	public static func listenForTransactionUpdates(finishAutomatically: Bool = true, updateBlock: TransactionUpdate?) -> TransactionObserverHandler
	{
		return shared.listenForTransactionUpdates(finishAutomatically: finishAutomatically, updateBlock: updateBlock)
	}
    
    public static func removeListenerForTransactionUpdates(_ handler: TransactionObserverHandler)
    {
        shared.removeListenerForTransactionUpdates(handler)
    }
	
	public static func retrieveProducts(productIds: Set<String>) async throws -> [Product]
	{
		try await shared.retrieveProducts(productIds: productIds)
	}
	
	@discardableResult
	public static func purchase(product: Product,
								quantity: Int = 1,
								finishAutomatically: Bool = true,
								appAccountToken: UUID? = nil,
								simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase
	{
		try await shared.purchase(product: product,
								  quantity: quantity,
								  finishAutomatically: finishAutomatically,
								  appAccountToken: appAccountToken,
								  simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
	}
	
	public static func restorePurchases() async throws
	{
		try await AppStore.sync()
	}
	
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	public static func beginRefundProcess(for product: Product, in scene: UIWindowScene) async throws
	{
		try await shared.beginRefundProcess(for: product.id, in: scene)
	}
	
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	public static func beginRefundProcess(for productID: String, in scene: UIWindowScene) async throws
	{
		try await shared.beginRefundProcess(for: productID, in: scene)
	}
	
	@available(iOS 15.0, *)
	@available(macOS, unavailable)
	@available(watchOS, unavailable)
	@available(tvOS, unavailable)
	public static func showManageSubscriptions(in scene: UIWindowScene) async throws
	{
		try await AppStore.showManageSubscriptions(in: scene)
	}
	
	public static func activeSubscriptions(onlyRenewable: Bool = true) async throws -> [Transaction]
	{
		var txs: [Transaction] = []
		
		for await result in Transaction.currentEntitlements
		{
			do {
				let transaction = try checkVerified(result)
				
				if transaction.productType == .autoRenewable ||
					(!onlyRenewable && transaction.productType == .nonRenewable)
				{
                    txs.append(transaction)
				}
			} catch {
				throw error
			}
		}
		
		return Array(txs)
	}
    
    public static func activeSubscriptionIds(onlyRenewable: Bool = true) async throws -> [String]
    {
        return try await activeSubscriptions(onlyRenewable: onlyRenewable).map { $0.productID}
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
