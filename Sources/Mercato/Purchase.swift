import StoreKit

/// A wrapper around StoreKit's `Product` and `Transaction` objects, providing a convenient interface for handling in-app purchases.
public struct Purchase: Sendable {
    /// The product associated with the purchase.
    public let product: Product

    /// The result associated with the purchase.
    public let result: VerificationResult<Transaction>

    /// A flag indicating whether the transaction needs to be finished manually.
    public let needsFinishTransaction: Bool
}

extension Purchase {
    /// The transaction associated with the purchase.
    public var transaction: Transaction {
        result.unsafePayloadValue
    }

    /// The identifier of the purchased product.
    ///
    /// This is derived from the `productID` property of the `transaction` object.
    public var productId: String {
        product.id
    }

    /// The quantity of the purchased product.
    ///
    /// This is derived from the `purchasedQuantity` property of the `transaction` object.
    public var quantity: Int {
        transaction.purchasedQuantity
    }

    /// Completes the transaction by calling the `finish()` method on the `transaction` object.
    ///
    /// This should be called if `needsFinishTransaction` is `true`.
    public func finish() async {
        await transaction.finish()
    }
}
