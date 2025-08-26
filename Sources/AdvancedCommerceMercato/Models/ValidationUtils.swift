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

// MARK: - Validatable

public protocol Validatable {
    func validate() throws
}

// MARK: - ValidationError

public enum ValidationError: Error {
    case invalidLength(String)
    case invalidValue(String)
}

// MARK: LocalizedError

extension ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLength(let msg),
             .invalidValue(let msg):
            msg
        }
    }
}

// MARK: - ValidationUtils

public enum ValidationUtils {
    enum Constants {
        static let kCurrencyCodeLength = 3
        static let kMaximumStorefrontLength = 10
        static let kMaximumRequestReferenceIdLength = 36
        static let kMaximumDescriptionLength = 45
        static let kMaximumDisplayNameLength = 30
        static let kMaximumSkuLength = 128
        static let kISOCurrencyRegex = "^[A-Z]{3}$"
    }

    /// Validates currency code according to ISO 4217 standard.
    /// - Parameter currency: The currency code to validate
    /// - Throws: ValidationError if validation fails
    public static func validateCurrency(_ currency: String) throws {
        guard currency.count == Constants.kCurrencyCodeLength else {
            throw ValidationError.invalidLength("Currency must be a 3-letter ISO 4217 code")
        }
        guard currency.range(of: Constants.kISOCurrencyRegex, options: .regularExpression) != nil else {
            throw ValidationError.invalidValue("Currency must contain only uppercase letters")
        }
    }

    /// Validates tax code is not empty.
    /// - Parameter taxCode: The tax code to validate
    /// - Throws: ValidationError if validation fails
    public static func validateTaxCode(_ taxCode: String) throws {
        guard !taxCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidValue("Tax code cannot be empty")
        }
    }

    /// Validates transactionId is not empty.
    /// - Parameter transactionId: The transaction ID to validate
    /// - Throws: ValidationError if validation fails
    public static func validateTransactionId(_ transactionId: String) throws {
        guard !transactionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidValue("Transaction ID cannot be empty")
        }
    }

    /// Validates target product ID is not empty.
    /// - Parameter targetProductId: The target product ID to validate
    /// - Throws: ValidationError if validation fails
    public static func validateTargetProductId(_ targetProductId: String) throws {
        guard !targetProductId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidValue("Target Product ID cannot be empty")
        }
    }

    /// Validates UUID is not null and its string representation doesn't exceed maximum length.
    /// - Parameter uuid: The UUID to validate
    /// - Throws: ValidationError if validation fails
    public static func validUUID(_ uuid: UUID) throws {
        let uuidString = uuid.uuidString
        guard uuidString.count <= Constants.kMaximumRequestReferenceIdLength else {
            throw ValidationError.invalidLength("UUID string representation cannot exceed \(Constants.kMaximumRequestReferenceIdLength) characters")
        }
    }

    /// Validates price is not null and non-negative.
    /// - Parameter price: The price to validate
    /// - Throws: ValidationError if validation fails
    public static func validatePrice(_ price: Int64) throws {
        guard price >= 0 else {
            throw ValidationError.invalidValue("Price cannot be negative")
        }
    }

    /// Validates description does not exceed maximum length.
    /// For required fields, caller should ensure description is not null before calling this method.
    /// - Parameter description: The description to validate
    /// - Throws: ValidationError if validation fails
    public static func validateDescription(_ description: String) throws {
        guard description.count <= Constants.kMaximumDescriptionLength else {
            throw ValidationError.invalidLength("Description length longer than maximum allowed")
        }
    }

    /// Validates display name does not exceed maximum length.
    /// For required fields, caller should ensure displayName is not null before calling this method.
    /// - Parameter displayName: The display name to validate
    /// - Throws: ValidationError if validation fails
    public static func validateDisplayName(_ displayName: String) throws {
        guard displayName.count <= Constants.kMaximumDisplayNameLength else {
            throw ValidationError.invalidLength("DisplayName length longer than maximum allowed")
        }
    }

    /// Validates SKU does not exceed maximum length.
    /// - Parameter sku: The SKU to validate
    /// - Throws: ValidationError if validation fails
    public static func validateSku(_ sku: String) throws {
        guard sku.count <= Constants.kMaximumSkuLength else {
            throw ValidationError.invalidLength("SKU length longer than maximum allowed")
        }
    }

    /// Validates SKU does not exceed maximum length.
    /// - Parameter sku: The SKU to validate
    /// - Throws: ValidationError if validation fails
    public static func validateStorefront(_ storefront: String) throws {
        guard storefront.count <= Constants.kMaximumStorefrontLength else {
            throw ValidationError.invalidLength("Storefront length longer than maximum allowed")
        }
    }
}
