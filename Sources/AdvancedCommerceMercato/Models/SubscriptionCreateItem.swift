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

// MARK: - SubscriptionCreateItem

/// The data that describes a subscription item.
///
/// [Advanced Commerce API Documentation](https://developer.apple.com/documentation/advancedcommerceapi/SubscriptionCreateItem)
public struct SubscriptionCreateItem: Decodable, Encodable {

    /// The SKU identifier for the item.
    ///
    /// [SKU](https://developer.apple.com/documentation/advancedcommerceapi/sku)
    public var sku: String

    /// The description of the item.
    ///
    /// [Description](https://developer.apple.com/documentation/advancedcommerceapi/description)
    public var description: String

    /// The display name of the item.
    ///
    /// [Display Name](https://developer.apple.com/documentation/advancedcommerceapi/displayname)
    public var displayName: String

    /// The number of periods for billing.
    ///
    /// [Offer](https://developer.apple.com/documentation/advancedcommerceapi/offer)
    public var offer: Offer?

    /// The price in milliunits.
    ///
    /// [Price](https://developer.apple.com/documentation/advancedcommerceapi/price)
    public var price: Int64


    public init(
        sku: String,
        description: String,
        displayName: String,
        offer: Offer?,
        price: Int64
    ) {
        self.sku = sku
        self.description = description
        self.displayName = displayName
        self.offer = offer
        self.price = price
    }

    public enum CodingKeys: String, CodingKey {
        case sku = "SKU"
        case description
        case displayName
        case offer
        case price
    }
}

// MARK: Validatable

extension SubscriptionCreateItem: Validatable {
    public func validate() throws {
        try ValidationUtils.validateSku(sku)
        try ValidationUtils.validateDescription(description)
        try ValidationUtils.validateDisplayName(displayName)
        try ValidationUtils.validatePrice(price)
    }
}
