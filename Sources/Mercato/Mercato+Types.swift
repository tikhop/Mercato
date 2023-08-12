//
//  File.swift
//
//
//  Created by Pavel Tikhonenko on 09.10.2021.
//


import StoreKit

// MARK: - MercatoError

// MARK: MercatoError
public enum MercatoError: Error {
    case storeKit(error: StoreKitError)
    case purchase(error: Product.PurchaseError)
    case purchaseCanceledByUser
    case userCancelledRefundProcess
    case purchaseIsPending
    case failedVerification
    case genericError
}

// MARK: - Purchase

// MARK: Purchase
public struct Purchase {
    public let product: Product
    public let transaction: Transaction
    public let needsFinishTransaction: Bool
}

extension Purchase {
    public var productId: String {
        transaction.productID
    }

    public var quantity: Int {
        transaction.purchasedQuantity
    }

    public func finish() async {
        await transaction.finish()
    }
}
