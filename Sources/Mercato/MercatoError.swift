// MIT License
//
// Copyright (c) 2021-2025 Pavel T
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import StoreKit

// MARK: - MercatoError

/// `MercatoError` categorizes errors related to StoreKit operations, purchases, and other potential issues
/// that might arise during the execution
public enum MercatoError: Error, Sendable {
    /// An error originating from StoreKit operations.
    case storeKit(error: StoreKitError)

    /// An error related to the purchase process.
    case purchase(error: Product.PurchaseError)

    /// An error related to the refund process.
    case refund(error: Transaction.RefundRequestError)

    /// An error indicating that the user canceled the action..
    case canceledByUser

    /// An error indicating that the purchase is pending.
    case purchaseIsPending

    /// An error indicating that the verification of a purchase failed.
    case failedVerification(payload: Transaction, error: VerificationResult<Transaction>.VerificationError)

    case noTransactionForSpecifiedProduct

    case noSubscriptionInTheProduct

    case productNotFound(String)

    /// An unknown error occurred.
    case unknown(error: Error?)
}

// MARK: LocalizedError

extension MercatoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .storeKit(error: let error):
            return error.errorDescription
        case .purchase(error: let error):
            return error.errorDescription
        case .refund(error: let error):
            return error.errorDescription
        case .canceledByUser:
            return "This error happens when user cancels purchase flow"
        case .purchaseIsPending:
            return "This error happens when purchase in pending flow (e.g. parental control is on)"
        case .failedVerification:
            return "This error happens when system is unable to verify Store Kit transaction"
        case .noTransactionForSpecifiedProduct:
            return "This error happens when system is unable to retrieve transaction for specified product"
        case .noSubscriptionInTheProduct:
            return "This error happens when product doesn't have subsciption"
        case .unknown(error: let error):
            return "Unknown error: \(String(describing: error)), Description: \(error?.localizedDescription ?? "Description is missing")"
        case .productNotFound(let id):
            return "This error happens when product for id = \(id) not found"
        }
    }

    package static func wrapped(error: any Error) -> MercatoError {
        if let mercatoError = error as? MercatoError {
            return mercatoError
        } else if let storeKitError = error as? StoreKitError {
            if case .userCancelled = storeKitError {
                return MercatoError.canceledByUser
            }

            return MercatoError.storeKit(error: storeKitError)

        } else if let error = error as? Product.PurchaseError {
            return MercatoError.purchase(error: error)
        } else {
            return MercatoError.unknown(error: error)
        }
    }
}

