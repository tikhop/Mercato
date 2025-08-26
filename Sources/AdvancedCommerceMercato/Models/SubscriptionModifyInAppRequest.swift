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

// MARK: - SubscriptionModifyInAppRequest

/// The request data your app provides to make changes to an auto-renewable subscription.
///
/// [SubscriptionModifyInAppRequest](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionmodifyinapprequest)
public struct SubscriptionModifyInAppRequest: Decodable, Encodable {

    /// The operation type for this request.
    public var operation: String = RequestOperation.modifySubscription.rawValue

    /// The version of this request.
    public var version: String = RequestVersion.v1.rawValue

    /// The metadata to include in server requests.
    ///
    /// [requestInfo](https://developer.apple.com/documentation/advancedcommerceapi/requestinfo)
    public var requestInfo: RequestInfo

    /// The data your app provides to add items when it makes changes to an auto-renewable subscription.
    ///
    /// [SubscriptionModifyAddItem](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionmodifyadditem)
    public var addItems: [SubscriptionModifyAddItem]?

    /// The data your app provides to change an item of an auto-renewable subscription.
    ///
    /// [SubscriptionModifyChangeItem](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionmodifychangeitem)
    public var changeItems: [SubscriptionModifyChangeItem]?

    /// The data your app provides to remove items from an auto-renewable subscription.
    ///
    /// [SubscriptionModifyRemoveItem](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionmodifyremoveitem)
    public var removeItems: [SubscriptionModifyRemoveItem]?

    /// The currency of the price of the product.
    ///
    /// [currency](https://developer.apple.com/documentation/advancedcommerceapi/currency)
    public var currency: String?

    /// The data your app provides to change the description and display name of an auto-renewable subscription.
    ///
    /// [SubscriptionModifyDescriptors](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionmodifydescriptors)
    public var descriptors: SubscriptionModifyDescriptors?

    /// The data your app provides to change the period of an auto-renewable subscription.
    ///
    /// [SubscriptionModifyPeriodChange](https://developer.apple.com/documentation/advancedcommerceapi/subscriptionmodifyperiodchange)
    public var periodChange: SubscriptionModifyPeriodChange?

    /// A Boolean value that determines whether to keep the existing billing cycle with the change you request.
    ///
    /// [retainBillingCycle](https://developer.apple.com/documentation/advancedcommerceapi/retainbillingcycle)
    public var retainBillingCycle: Bool

    /// The storefront for the transaction.
    ///
    /// [storefront](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargecreaterequest)
    public var storefront: String?

    /// The tax code for this product.
    ///
    /// [taxCode](https://developer.apple.com/documentation/advancedcommerceapi/taxcode)
    public var taxCode: String?

    /// A unique identifier that the App Store generates for a transaction.
    ///
    /// [transactionId](https://developer.apple.com/documentation/advancedcommerceapi/transactionid)
    public var transactionId: String

    init(
        requestInfo: RequestInfo,
        addItems: [SubscriptionModifyAddItem]? = nil,
        changeItems: [SubscriptionModifyChangeItem]? = nil,
        removeItems: [SubscriptionModifyRemoveItem]? = nil,
        currency: String? = nil,
        descriptors: SubscriptionModifyDescriptors? = nil,
        periodChange: SubscriptionModifyPeriodChange? = nil,
        retainBillingCycle: Bool,
        storefront: String? = nil,
        taxCode: String? = nil,
        transactionId: String
    ) {
        self.requestInfo = requestInfo
        self.addItems = addItems
        self.changeItems = changeItems
        self.removeItems = removeItems
        self.currency = currency
        self.descriptors = descriptors
        self.periodChange = periodChange
        self.retainBillingCycle = retainBillingCycle
        self.storefront = storefront
        self.taxCode = taxCode
        self.transactionId = transactionId
    }

    public enum CodingKeys: String, CodingKey {
        case operation
        case version
        case requestInfo
        case addItems
        case changeItems
        case currency
        case descriptors
        case periodChange
        case removeItems
        case retainBillingCycle
        case storefront
        case taxCode
        case transactionId
    }
}

// MARK: - SubscriptionModifyInAppRequest Builder
extension SubscriptionModifyInAppRequest {
    public func addItems(_ addItems: [SubscriptionModifyAddItem]?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.addItems = addItems
        return updated
    }

    public func addAddItem(_ addItem: SubscriptionModifyAddItem) -> SubscriptionModifyInAppRequest {
        var updated = self
        if updated.addItems == nil {
            updated.addItems = []
        }
        updated.addItems?.append(addItem)
        return updated
    }

    public func changeItems(_ changeItems: [SubscriptionModifyChangeItem]?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.changeItems = changeItems
        return updated
    }

    public func addChangeItem(_ changeItem: SubscriptionModifyChangeItem) -> SubscriptionModifyInAppRequest {
        var updated = self
        if updated.changeItems == nil {
            updated.changeItems = []
        }
        updated.changeItems?.append(changeItem)
        return updated
    }

    public func currency(_ currency: String?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.currency = currency
        return updated
    }

    public func descriptors(_ descriptors: SubscriptionModifyDescriptors?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.descriptors = descriptors
        return updated
    }

    public func periodChange(_ periodChange: SubscriptionModifyPeriodChange?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.periodChange = periodChange
        return updated
    }

    public func removeItems(_ removeItems: [SubscriptionModifyRemoveItem]?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.removeItems = removeItems
        return updated
    }

    public func addRemoveItem(_ removeItem: SubscriptionModifyRemoveItem) -> SubscriptionModifyInAppRequest {
        var updated = self
        if updated.removeItems == nil {
            updated.removeItems = []
        }
        updated.removeItems?.append(removeItem)
        return updated
    }

    public func storefront(_ storefront: String?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.storefront = storefront
        return updated
    }

    public func taxCode(_ taxCode: String?) -> SubscriptionModifyInAppRequest {
        var updated = self
        updated.taxCode = taxCode
        return updated
    }
}

extension SubscriptionModifyInAppRequest: Validatable {
    public func validate() throws {
        try requestInfo.validate()

        if let addItems { try addItems.forEach { try $0.validate() } }
        if let changeItems { try changeItems.forEach { try $0.validate() } }
        if let removeItems { try removeItems.forEach { try $0.validate() } }
        if let descriptors { try descriptors.validate() }
        if let currency { try ValidationUtils.validateCurrency(currency) }
        if let taxCode { try ValidationUtils.validateTaxCode(taxCode) }
        if let storefront { try ValidationUtils.validateStorefront(storefront) }
    }
}
