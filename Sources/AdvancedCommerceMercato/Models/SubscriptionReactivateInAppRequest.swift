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

// MARK: - SubscriptionReactivateInAppRequest

/// The request data your app provides to reactivate an auto-renewable subscription.
///
/// [SubscriptionReactivateInAppRequest](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionreactivateinapprequest)
public struct SubscriptionReactivateInAppRequest: Decodable, Encodable {

    /// The operation type for this request.
    public var operation: String = RequestOperation.reactivateSubscription.rawValue

    /// The version of this request.
    public var version: String = RequestVersion.v1.rawValue

    /// The metadata to include in server requests.
    ///
    /// [requestInfo](https://developer.apple.com/documentation/advancedcommerceapi/requestinfo)
    public var requestInfo: RequestInfo

    /// The list of items to reactivate in the subscription.
    ///
    /// [SubscriptionReactivateItem](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionreactivateitem)
    public var items: [SubscriptionReactivateItem]?

    /// The transaction identifier, which may be an original transaction identifier, of any transaction belonging to the customer. Provide this field to limit the notification history request to this one customer.
    /// Include either the transactionId or the notificationType in your query, but not both.
    ///
    /// [transactionId](https://developer.apple.com/documentation/appstoreserverapi/transactionid)
    public var transactionId: String

    /// The storefront for the transaction.
    ///
    /// [storefront](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
    public var storefront: String?

    public init(
        requestInfo: RequestInfo,
        items: [SubscriptionReactivateItem]? = nil,
        transactionId: String,
        storefront: String? = nil
    ) {
        self.requestInfo = requestInfo
        self.items = items
        self.transactionId = transactionId
        self.storefront = storefront
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case operation
        case version
        case requestInfo
        case transactionId
        case items
        case storefront
    }
}

// MARK: SubscriptionReactivateInAppRequest Builder
extension SubscriptionReactivateInAppRequest {
    public func items(_ items: [SubscriptionReactivateItem]) -> SubscriptionReactivateInAppRequest {
        var updated = self
        updated.items = items
        return updated
    }

    public func addItem(_ item: SubscriptionReactivateItem) -> SubscriptionReactivateInAppRequest {
        var updated = self
        if updated.items == nil {
            updated.items = []
        }
        updated.items?.append(item)
        return updated
    }

    public func storefront(_ storefront: String) -> SubscriptionReactivateInAppRequest {
        var updated = self
        updated.storefront = storefront
        return updated
    }
}

extension SubscriptionReactivateInAppRequest: Validatable {
    public func validate() throws {
        try requestInfo.validate()

        try ValidationUtils.validateTransactionId(transactionId)

        if let items { try items.forEach { try $0.validate() } }
        if let storefront { try ValidationUtils.validateStorefront(storefront) }
    }
}
