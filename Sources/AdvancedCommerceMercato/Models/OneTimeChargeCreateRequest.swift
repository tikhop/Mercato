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

// MARK: - OneTimeChargeCreateRequest

/// The request data your app provides when a customer purchases a one-time-charge product.
///
/// [OneTimeChargeCreateRequest](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
public struct OneTimeChargeCreateRequest: Codable {

    /// The operation type for this request.
    public var operation: String = RequestOperation.oneTimeCharge.rawValue

    /// The version of this request.
    public var version: String = RequestVersion.v1.rawValue

    /// The metadata to include in server requests.
    ///
    /// [requestInfo](https://developer.apple.com/documentation/advancedcommerceapi/requestinfo)
    public var requestInfo: RequestInfo

    /// The currency of the price of the product.
    ///
    /// [currency](https://developer.apple.com/documentation/advancedcommerceapi/currency)
    public var currency: String

    /// The details of the product for purchase.
    ///
    /// [OneTimeChargeItem](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargeitem)
    public var item: OneTimeChargeItem

    /// The storefront for the transaction.
    ///
    /// [storefront](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
    public var storefront: String?

    /// The tax code for this product.
    ///
    /// [taxCode](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
    public var taxCode: String

    /// Convenience initializer
    public init(
        currency: String,
        item: OneTimeChargeItem,
        requestInfo: RequestInfo,
        taxCode: String,
        storefront: String? = nil
    ) {
        self.requestInfo = requestInfo
        self.currency = currency
        self.item = item
        self.taxCode = taxCode
        self.storefront = storefront
    }
}

// MARK: Validatable

extension OneTimeChargeCreateRequest: Validatable {
    public func validate() throws {
        try requestInfo.validate()

        try ValidationUtils.validateCurrency(currency)
        try ValidationUtils.validateTaxCode(taxCode)
        if let storefront { try ValidationUtils.validateStorefront(storefront) }
    }
}
