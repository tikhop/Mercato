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

import StoreKit

// MARK: - Purchase

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
