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

// MARK: - SubscriptionModifyRemoveItem

/// An item for removing from Advanced Commerce subscription modifications.
///
/// [SubscriptionModifyRemoveItem](https://developer.apple.com/documentation/advancedcommerceapi/SubscriptionModifyRemoveItem)
public struct SubscriptionModifyRemoveItem: Decodable, Encodable {

    /// The SKU identifier for the item.
    ///
    /// [SKU](https://developer.apple.com/documentation/advancedcommerceapi/sku)
    public var sku: String

    init(sku: String) {
        self.sku = sku
    }

    public enum CodingKeys: String, CodingKey {
        case sku = "SKU"
    }
}

// MARK: Validatable

extension SubscriptionModifyRemoveItem: Validatable {
    public func validate() throws {
        try ValidationUtils.validateSku(sku)
    }
}
