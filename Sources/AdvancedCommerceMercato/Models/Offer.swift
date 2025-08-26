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

// MARK: - Offer

/// A discount offer for an auto-renewable subscription.
///
/// [Offer](https://developer.apple.com/documentation/advancedcommerceapi/offer)
public struct Offer: Codable {

    /// The period of the offer.
    public var period: OfferPeriod

    /// The number of periods the offer is active.
    public var periodCount: Int32

    /// The offer price, in milliunits.
    ///
    /// [Price](https://developer.apple.com/documentation/advancedcommerceapi/price)
    public var price: Int64

    /// The reason for the offer.
    public var reason: OfferReason

    public init(
        period: OfferPeriod,
        periodCount: Int32,
        price: Int64,
        reason: OfferReason
    ) {
        self.period = period
        self.periodCount = periodCount
        self.price = price
        self.reason = reason
    }

}

// MARK: Validatable

extension Offer: Validatable {
    public func validate() throws {
        try ValidationUtils.validatePrice(price)
    }
}
