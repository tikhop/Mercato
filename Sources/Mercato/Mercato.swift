import Foundation
import StoreKit

// MARK: - Mercato

public final class Mercato {
    private var purchaseController = PurchaseController()
    private var productService = ProductService()

    private var transactionUpdateListeners: [TransactionObserverHandler: TransactionObserver] = [:]
    private var allTransactionListeners: [TransactionObserverHandler: TransactionObserver] = [:]
    private var unfinishedTransactionListeners: [TransactionObserverHandler: TransactionObserver] = [:]
    private var currentEntitlementListeners: [TransactionObserverHandler: TransactionObserver] = [:]
    
    func listenForTransactionUpdates(updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        let handler = TransactionObserverHandler()
        let observer = TransactionObserver(transactionSequence: Transaction.updates, handler: updateBlock)
        transactionUpdateListeners[handler] = observer
        return handler
    }

    func removeListenerForTransactionUpdates(_ handler: TransactionObserverHandler) {
        let observer = transactionUpdateListeners[handler]
        observer?.stop()
        transactionUpdateListeners[handler] = nil
    }
    
    func listenForAllTransaction(updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        let handler = TransactionObserverHandler()
        let observer = TransactionObserver(transactionSequence: Transaction.all, handler: updateBlock)
        allTransactionListeners[handler] = observer
        return handler
    }

    func removeListenerForAllTransaction(_ handler: TransactionObserverHandler) {
        let observer = transactionUpdateListeners[handler]
        observer?.stop()
        allTransactionListeners[handler] = nil
    }

    func listenForUnfinishedTransaction(updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        let handler = TransactionObserverHandler()
        let observer = TransactionObserver(transactionSequence: Transaction.unfinished, handler: updateBlock)
        unfinishedTransactionListeners[handler] = observer
        return handler
    }

    func removeListenerForUnfinishedTransaction(_ handler: TransactionObserverHandler) {
        let observer = transactionUpdateListeners[handler]
        observer?.stop()
        unfinishedTransactionListeners[handler] = nil
    }
    
    func listenForCurrentEntitlement(onlyRenewable: Bool, updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        let handler = TransactionObserverHandler()
        let observer = CurrentEntitlementObserver(onlyRenewable: onlyRenewable, handler: updateBlock)
        currentEntitlementListeners[handler] = observer
        return handler
    }

    func removeListenerCurrentEntitlement(_ handler: TransactionObserverHandler) {
        let observer = transactionUpdateListeners[handler]
        observer?.stop()
        currentEntitlementListeners[handler] = nil
    }
    
    // TODO: throw an error if productId are invalid
    public func retrieveProducts(productIds: Set<String>) async throws -> [Product] {
        try await productService.retrieveProducts(productIds: productIds)
    }

    @discardableResult
    public func purchase(product: Product, quantity: Int = 1, finishAutomatically: Bool = true, appAccountToken: UUID? = nil,
                         simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase {
        try await purchaseController.makePurchase(product: product, quantity: quantity, finishAutomatically: finishAutomatically, appAccountToken: appAccountToken,
                                                  simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
    }

    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    func beginRefundProcess(for productID: String, in scene: UIWindowScene) async throws {
        guard case .verified(let transaction) = await Transaction.latest(for: productID) else { throw MercatoError.failedVerification }

        do {
            let status = try await transaction.beginRefundRequest(in: scene)

            switch status {
            case .userCancelled:
                throw MercatoError.userCancelledRefundProcess
            case .success:
                break
            @unknown default:
                throw MercatoError.genericError
            }
        } catch {
            // TODO: return a specific error
            throw error
        }
    }

    private func cleanUp(listeners: [TransactionObserverHandler: TransactionObserver]) {
        for item in listeners {
            item.value.stop()
        }
    }
    
    deinit {
        cleanUp(listeners: transactionUpdateListeners)
        transactionUpdateListeners.removeAll()
        
        cleanUp(listeners: allTransactionListeners)
        allTransactionListeners.removeAll()
        
        cleanUp(listeners: unfinishedTransactionListeners)
        unfinishedTransactionListeners.removeAll()
        
        cleanUp(listeners: currentEntitlementListeners)
        currentEntitlementListeners.removeAll()
    }
}

extension Mercato {
    fileprivate static let shared: Mercato = .init()

    public static func listenForTransactionUpdates(updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        shared.listenForTransactionUpdates(updateBlock: updateBlock)
    }

    public static func removeListenerForTransactionUpdates(_ handler: TransactionObserverHandler) {
        shared.removeListenerForTransactionUpdates(handler)
    }

    public static func listenForAllTransaction(updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        shared.listenForAllTransaction(updateBlock: updateBlock)
    }

    public static func removeListenerForAllTransaction(_ handler: TransactionObserverHandler) {
        shared.removeListenerForAllTransaction(handler)
    }
    
    public static func listenForUnfinishedTransaction(updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        shared.listenForUnfinishedTransaction(updateBlock: updateBlock)
    }

    public static func removeListenerForUnfinishedTransaction(_ handler: TransactionObserverHandler) {
        shared.removeListenerForUnfinishedTransaction(handler)
    }
    
    public static func listenForCurrentEntitlement(onlyRenewable: Bool, updateBlock: @escaping TransactionUpdate) -> TransactionObserverHandler {
        shared.listenForCurrentEntitlement(onlyRenewable: onlyRenewable, updateBlock: updateBlock)
    }

    public static func removeListenerCurrentEntitlement(_ handler: TransactionObserverHandler) {
        shared.removeListenerCurrentEntitlement(handler)
    }
    
    public static func retrieveProducts(productIds: Set<String>) async throws -> [Product] {
        try await shared.retrieveProducts(productIds: productIds)
    }
    
    @discardableResult
    public static func purchase(product: Product,
                                quantity: Int = 1,
                                finishAutomatically: Bool = true,
                                appAccountToken: UUID? = nil,
                                simulatesAskToBuyInSandbox: Bool = false) async throws -> Purchase {
        try await shared.purchase(product: product,
                                  quantity: quantity,
                                  finishAutomatically: finishAutomatically,
                                  appAccountToken: appAccountToken,
                                  simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
    }

    public static func restorePurchases() async throws {
        try await AppStore.sync()
    }

    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public static func beginRefundProcess(for product: Product, in scene: UIWindowScene) async throws {
        try await shared.beginRefundProcess(for: product.id, in: scene)
    }

    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public static func beginRefundProcess(for productID: String, in scene: UIWindowScene) async throws {
        try await shared.beginRefundProcess(for: productID, in: scene)
    }

    @available(iOS 15.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public static func showManageSubscriptions(in scene: UIWindowScene) async throws {
        try await AppStore.showManageSubscriptions(in: scene)
    }
}


func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let safe):
        return safe
    case .unverified:
        throw MercatoError.failedVerification
    }
}
