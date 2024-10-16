import Foundation
import StoreKit

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
    case failedVerification

    /// An unknown error occurred.
    case unknown(error: Error?)
}

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
        case .unknown(error: let error):
            return "Unknown error: \(String(describing: error)), Description: \(error?.localizedDescription ?? "Description is missing")"
        }
    }
}

