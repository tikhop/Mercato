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

// MARK: - SubscriptionModifyChangeItem

/// An item for changing Advanced Commerce subscription modifications.
///
/// [SubscriptionModifyChangeItem](https://developer.apple.com/documentation/advancedcommerceapi/SubscriptionModifyChangeItem)
public struct SubscriptionModifyChangeItem: Codable {

    /// The SKU identifier for the item.
    ///
    /// [SKU](https://developer.apple.com/documentation/advancedcommerceapi/sku)
    public var sku: String

    /// The SKU identifier for the item.
    ///
    /// [SKU](https://developer.apple.com/documentation/advancedcommerceapi/sku)
    public var currentSku: String

    /// The description of the item.
    ///
    /// [Description](https://developer.apple.com/documentation/advancedcommerceapi/description)
    public var description: String

    /// The display name of the item.
    ///
    /// [Display Name](https://developer.apple.com/documentation/advancedcommerceapi/displayname)
    public var displayName: String

    /// When the modification takes effect.
    ///
    /// [Effective](https://developer.apple.com/documentation/advancedcommerceapi/effective)
    public var effective: Effective

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

    /// Reason
    ///
    /// [Reason](Reason)
    public var reason: Reason

    init(
        sku: String,
        currentSku: String,
        description: String,
        displayName: String,
        effective: Effective,
        offer: Offer? = nil,
        price: Int64,
        proratedPrice: Int64? = nil,
        reason: Reason
    ) {
        self.sku = sku
        self.currentSku = currentSku
        self.description = description
        self.displayName = displayName
        self.effective = effective
        self.offer = offer
        self.price = price
        self.proratedPrice = proratedPrice
        self.reason = reason
    }

    public enum CodingKeys: String, CodingKey {
        case sku = "SKU"
        case currentSku = "currentSKU"
        case description
        case displayName
        case effective
        case offer
        case price
        case proratedPrice
        case reason
    }
}

// MARK: Validatable

extension SubscriptionModifyChangeItem: Validatable {
    public func validate() throws {
        try offer?.validate()

        try ValidationUtils.validateSku(sku)
        try ValidationUtils.validateSku(currentSku)
        try ValidationUtils.validateDescription(description)
        try ValidationUtils.validateDisplayName(displayName)
        try ValidationUtils.validatePrice(price)

        if let proratedPrice { try ValidationUtils.validatePrice(proratedPrice) }
    }
}
