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
import StoreKit

typealias RenewalState = Product.SubscriptionInfo.RenewalState

extension Product {
    /// Indicates whether the product is eligible for an introductory offer.
    public var isEligibleForIntroOffer: Bool {
        get async {
            await subscription?.isEligibleForIntroOffer ?? false
        }
    }

    /// Indicates whether the product has an active subscription.
    public var hasActiveSubscription: Bool {
        get async {
            await (try? subscription?.status.first?.state == RenewalState.subscribed) ?? false
        }
    }

    /// Indicates whether the product has an intro offer.
    public var hasIntroductoryOffer: Bool {
        subscription?.introductoryOffer != nil
    }

    /// Indicates whether the product has an intro offer which is trial
    public var hasTrial: Bool {
        guard let offer = subscription?.introductoryOffer else { return false }

        return offer.paymentMode == .freeTrial
    }

    /// Indicates whether the product has an intro offer which is pay as you go
    public var hasPayAsYouGoOffer: Bool {
        guard let offer = subscription?.introductoryOffer else { return false }

        return offer.paymentMode == .payAsYouGo
    }

    /// Returns the price of the product, considering eligibility for an introductory offer.
    ///
    /// - Parameter isEligibleForIntroductoryOffer: A boolean indicating if the user is eligible for an introductory offer.
    /// - Returns: A decimal representing the price.
    public func price(isEligibleForIntroductoryOffer: Bool) -> Decimal {
        guard isEligibleForIntroductoryOffer,
              let introductoryOffer = subscription?.introductoryOffer,
              introductoryOffer.paymentMode != .freeTrial else {
            return price
        }

        return introductoryOffer.price
    }

    public func finalPrice(isEligibleForIntroductoryOffer: Bool) -> Decimal {
        guard isEligibleForIntroductoryOffer,
              let introductoryOffer = subscription?.introductoryOffer else {
            return price
        }

        if introductoryOffer.paymentMode == .freeTrial {
            return 0
        }

        return introductoryOffer.price
    }

    /// Returns price per day.
    /// NOTE: Return 0 if it's not a subscription.
    public var priceInDay: Decimal {
        guard let periodInDays = subscription?.periodInDays, periodInDays > 0 else { return 0 }
        return price / Decimal(periodInDays)
    }

    /// Returns the localized subscription period as a string.
    /// NOTE: Can be empty string if subscription doesn't exist
    public var localizedPeriod: String {
        subscription?.localizedPeriod ?? ""
    }
}

extension Product {
    /// A localized string representation of `price`.
    ///
    /// - Note: This uses the locale from StoreKit/App Store, not the user's device locale.
    ///         If you need to format the price using the user's locale, use the `price` property
    ///         with a custom NumberFormatter configured with the user's locale.
    public var localizedPrice: String {
        displayPrice
    }

    /// Returns the localized price of the product, considering eligibility for an introductory offer.
    ///
    /// - Parameter isEligibleForIntroductoryOffer: A boolean indicating if the user is eligible for an introductory offer.
    /// - Returns: A localized string representation of `price`.
    /// - Note: This uses the locale from StoreKit/App Store, not the user's device locale.
    ///         If you need to format the price using the user's locale, use the `price(isEligibleForIntroductoryOffer:)`
    ///         method with a custom NumberFormatter configured with the user's locale.
    public func localizedPrice(isEligibleForIntroductoryOffer: Bool) -> String {
        guard isEligibleForIntroductoryOffer,
              let introductoryPrice = subscription?.introductoryOffer,
              introductoryPrice.paymentMode != .freeTrial else {
            return localizedPrice
        }

        return introductoryPrice.displayPrice
    }

    /// Returns the locale used for the product's price.
    public var priceLocale: Locale {
        priceFormatStyle.locale
    }
}

extension Product.SubscriptionInfo {
    /// Returns the localized subscription period as a string.
    public var localizedPeriod: String {
        subscriptionPeriod.localizedPeriod
    }

    /// Returns the subscription period in days.
    public var periodInDays: Int {
        subscriptionPeriod.periodInDays
    }
}

extension Product.SubscriptionPeriod {
    /// Returns the localized period of the subscription as a string.
    public var localizedPeriod: String {
        var localizedPeriod = PeriodFormatter.format(
            unit: unit.toCalendarUnit(),
            numberOfUnits: numberOfUnits
        )

        let prefix = "1 "

        if let period = localizedPeriod, period.hasPrefix(prefix), numberOfUnits == 1 {
            localizedPeriod = String(period.dropFirst(prefix.count))
        }

        return localizedPeriod?.replacingOccurrences(of: " ", with: "\u{00a0}") ?? ""
    }

    /// Returns the subscription period in days.
    public var periodInDays: Int {
        switch unit {
        case .day:
            1 * numberOfUnits
        case .week:
            7 * numberOfUnits
        case .month:
            30 * numberOfUnits
        case .year:
            365 * numberOfUnits
        @unknown default:
            fatalError("unknown period")
        }
    }

    /// The number of units that the period represents.
    public var numberOfUnits: Int {
        value
    }
}

extension Product.SubscriptionPeriod.Unit {
    /// Converts the subscription period unit to an `NSCalendar.Unit`.
    ///
    /// - Returns: An `Calendar.Component` representing the period unit.
    func toCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case .day:
            .day
        case .month:
            .month
        case .week:
            .weekOfMonth
        case .year:
            .year
        @unknown default:
            .day
        }
    }
}

extension Product.SubscriptionOffer {

    /// Returns the localized price of the subscription offer as a string.
    public var localizedPrice: String {
        displayPrice
    }

    /// Returns the localized period of the subscription offer as a string.
    public var localizedPeriod: String {
        period.localizedPeriod
    }

    public var durationUnits: Int {
        period.numberOfUnits * periodCount
    }

    /// Returns the duration of the subscription offer in units.
    public var durationInDays: Int {
        period.periodInDays * periodCount
    }

    /// Returns the duration of the subscription offer in days.
    public var localizedDuration: String {
        var localizedDuration = PeriodFormatter.format(
            unit: period.unit.toCalendarUnit(),
            numberOfUnits: durationUnits
        )
        let prefix = "1 "

        if let duration = localizedDuration, duration.hasPrefix(prefix), durationUnits == 1 {
            localizedDuration = String(duration.dropFirst(prefix.count))
        }

        return localizedDuration?.replacingOccurrences(of: " ", with: "\u{00a0}") ?? ""
    }

    /// Returns the price per day of the subscription offer.
    public var priceInDay: Decimal {
        guard paymentMode != .freeTrial else {
            return 0
        }

        let periodInDays = period.periodInDays
        return price / Decimal(periodInDays)
    }
}

extension VerificationResult<Transaction> {
    var payload: Transaction {
        get throws (MercatoError) {
            switch self {
            case .verified(let payload):
                return payload
            case .unverified(let payload, let error):
                throw MercatoError.failedVerification(payload: payload, error: error)
            }
        }
    }
}
