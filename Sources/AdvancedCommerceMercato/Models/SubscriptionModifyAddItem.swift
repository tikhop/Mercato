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

// MARK: - SubscriptionModifyAddItem

/// An item for adding to Advanced Commerce subscription modifications.
///
/// [SubscriptionModifyAddItem](https://developer.apple.com/documentation/advancedcommerceapi/SubscriptionModifyAddItem)
public struct SubscriptionModifyAddItem: Decodable, Encodable {

    public init(
        sku: String,
        description: String,
        displayName: String,
        offer: Offer? = nil,
        price: Int64,
        proratedPrice: Int64?
    ) {
        self.sku = sku
        self.description = description
        self.displayName = displayName
        self.offer = offer
        self.price = price
        self.proratedPrice = proratedPrice
    }

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

    /// Offer.
    ///
    /// [offer](https://developer.apple.com/documentation/advancedcommerceapi/offer)
    public var offer: Offer?

    /// The price, in milliunits of the currency, of the one-time charge product.
    ///
    /// [Price](https://developer.apple.com/documentation/advancedcommerceapi/price)
    public var price: Int64

    /// The price, in milliunits of the currency, of the one-time charge product.
    ///
    /// [proratedPrice](https://developer.apple.com/documentation/advancedcommerceapi/proratedPrice)
    public var proratedPrice: Int64?

    public enum CodingKeys: String, CodingKey {
        case sku = "SKU"
        case description
        case displayName
        case offer
        case price
        case proratedPrice
    }
}

// MARK: Validatable

extension SubscriptionModifyAddItem: Validatable {
    public func validate() throws {
        try offer?.validate()

        try ValidationUtils.validateSku(sku)
        try ValidationUtils.validateDescription(description)
        try ValidationUtils.validateDisplayName(displayName)
        try ValidationUtils.validatePrice(price)

        if let proratedPrice { try ValidationUtils.validatePrice(proratedPrice) }
    }
}
