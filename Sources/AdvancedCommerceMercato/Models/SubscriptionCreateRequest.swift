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

// MARK: - SubscriptionCreateRequest

/// The metadata your app provides when a customer purchases an auto-renewable subscription.
///
/// [SubscriptionCreateRequest](https://developer.apple.com/documentation/advancedcommerceapi/subscriptioncreaterequest)
public struct SubscriptionCreateRequest: Decodable, Encodable {

    /// The operation type for this request.
    public var operation: String = RequestOperation.createSubscription.rawValue

    /// The version of this request.
    public var version: String = RequestVersion.v1.rawValue

    /// The currency of the price of the product.
    ///
    /// [currency](https://developer.apple.com/documentation/advancedcommerceapi/currency)
    public var currency: String

    /// The display name and description of a subscription product.
    ///
    /// [Descriptors](https://developer.apple.com/documentation/advancedcommerceapi/descriptors)
    public var descriptors: Descriptors

    /// The details of the subscription product for purchase.
    ///
    /// [SubscriptionCreateItem](https://developer.apple.com/documentation/advancedcommerceapi/subscriptioncreateitem)
    public var items: [SubscriptionCreateItem]

    /// The duration of a single cycle of an auto-renewable subscription.
    ///
    /// [period](https://developer.apple.com/documentation/advancedcommerceapi/period)
    public var period: Period

    /// The identifier of a previous transaction for the subscription.
    ///
    /// [transactionId](https://developer.apple.com/documentation/advancedcommerceapi/transactionid)
    public var previousTransactionId: String?

    /// The metadata to include in server requests.
    ///
    /// [requestInfo](https://developer.apple.com/documentation/advancedcommerceapi/requestinfo)
    public var requestInfo: RequestInfo

    /// The storefront for the transaction.
    ///
    /// [storefront](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
    public var storefront: String?

    /// The tax code for this product.
    ///
    /// [taxCode](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
    public var taxCode: String

    public init(
        currency: String,
        descriptors: Descriptors,
        items: [SubscriptionCreateItem],
        period: Period,
        previousTransactionId: String? = nil,
        requestInfo: RequestInfo,
        storefront: String? = nil,
        taxCode: String
    ) {
        self.currency = currency
        self.descriptors = descriptors
        self.items = items
        self.period = period
        self.previousTransactionId = previousTransactionId
        self.requestInfo = requestInfo
        self.storefront = nil
        self.taxCode = taxCode
    }


    public enum CodingKeys: String, CodingKey, CaseIterable {
        case operation
        case version
        case currency
        case descriptors
        case items
        case period
        case previousTransactionId
        case requestInfo
        case storefront
        case taxCode
    }
}

// MARK: Validatable

extension SubscriptionCreateRequest: Validatable {
    public func validate() throws {
        try descriptors.validate()
        try requestInfo.validate()

        try items.forEach { try $0.validate() }
        try ValidationUtils.validateCurrency(currency)
        try ValidationUtils.validateTaxCode(taxCode)

        if let storefront { try ValidationUtils.validateStorefront(storefront) }
        if let previousTransactionId { try ValidationUtils.validateTransactionId(previousTransactionId) }
    }
}
