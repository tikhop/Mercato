//
//  File.swift
//  Mercato
//
//  Created by PT on 8/26/25.
//

import StoreKit

// MARK: - AdvancedCommercePurchase

/// A wrapper around StoreKit's `AdvancedCommerceProduct` and `Transaction` objects, providing a convenient interfae for handling in-app purchases.
@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
public struct AdvancedCommercePurchase: Sendable {
    /// The product associated with the purchase.
    public let product: AdvancedCommerceProduct

    /// The result associated with the purchase.
    public let result: VerificationResult<Transaction>

    /// A flag indicating whether the transaction needs to be finished manually.
    public let needsFinishTransaction: Bool
}

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
extension AdvancedCommercePurchase {
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
