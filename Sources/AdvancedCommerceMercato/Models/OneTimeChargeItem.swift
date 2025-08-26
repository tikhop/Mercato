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

// MARK: - OneTimeChargeItem

/// The details of a one-time charge product, including its display name, price, SKU, and metadata.
///
/// [OneTimeChargeItem](https://developer.apple.com/documentation/advancedcommerceapi/onetimechargeitem)
public struct OneTimeChargeItem: Decodable, Encodable {

    /// The product identifier.
    ///
    /// [SKU](https://developer.apple.com/documentation/advancedcommerceapi/sku)
    public var sku: String

    /// A description of the product that doesn’t display to customers.
    ///
    /// [description](https://developer.apple.com/documentation/advancedcommerceapi/description)
    public var description: String

    /// The product name, suitable for display to customers.
    ///
    /// [displayName](https://developer.apple.com/documentation/advancedcommerceapi/displayName)
    public var displayName: String

    /// The price, in milliunits of the currency, of the one-time charge product.
    ///
    /// [Price](https://developer.apple.com/documentation/advancedcommerceapi/price)
    public var price: Int64

    public init(sku: String, description: String, displayName: String, price: Int64) {
        self.sku = sku
        self.description = description
        self.displayName = displayName
        self.price = price
    }

    public enum CodingKeys: String, CodingKey {
        case sku = "SKU"
        case description
        case displayName
        case price
    }
}

// MARK: Validatable

extension OneTimeChargeItem: Validatable {
    public func validate() throws {
        try ValidationUtils.validateSku(sku)
        try ValidationUtils.validateDescription(description)
        try ValidationUtils.validateDisplayName(displayName)
        try ValidationUtils.validatePrice(price)
    }
}
