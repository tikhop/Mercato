//
//  File.swift
//
//
//  Created by Pavel Tikhonenko on 10.10.2021.
//

import Foundation
import StoreKit

typealias RenewalState = Product.SubscriptionInfo.RenewalState

public extension Product {
    /// Indicates whether the product is eligible for an introductory offer.
    var isEligibleForIntroOffer: Bool {
        get async {
            await subscription?.isEligibleForIntroOffer ?? false
        }
    }

    /// Indicates whether the product has an active subscription.
    var hasActiveSubscription: Bool {
        get async {
            await (try? subscription?.status.first?.state == RenewalState.subscribed) ?? false
        }
    }

    /// Indicates whether the product has an intro offer.
    var hasIntroductoryOffer: Bool {
        subscription?.introductoryOffer != nil
    }

    /// Indicates whether the product has an intro offer which is trial
    var hasTrial: Bool {
        guard let offer = subscription?.introductoryOffer else { return false }

        return offer.paymentMode == .freeTrial
    }

    /// Indicates whether the product has an intro offer which is pay as you go
    var hasPayAsYouGoOffer: Bool {
        guard let offer = subscription?.introductoryOffer else { return false }

        return offer.paymentMode == .payAsYouGo
    }
}

public extension Product {
    /// Returns the price of the product, considering eligibility for an introductory offer.
    ///
    /// - Parameter isEligibleForIntroductoryOffer: A boolean indicating if the user is eligible for an introductory offer.
    /// - Returns: A decimal representing the price.
    func price(isEligibleForIntroductoryOffer: Bool) -> Decimal {
        guard isEligibleForIntroductoryOffer,
              let introductoryOffer = subscription?.introductoryOffer,
              introductoryOffer.paymentMode != .freeTrial else {
            return price
        }

        return introductoryOffer.price
    }

    func finalPrice(isEligibleForIntroductoryOffer: Bool) -> Decimal {
        guard isEligibleForIntroductoryOffer,
              let introductoryOffer = subscription?.introductoryOffer else {
            return price
        }

        if introductoryOffer.paymentMode == .freeTrial {
            return 0
        }

        return introductoryOffer.price
    }

    /// A localized string representation of `price`.
    var localizedPrice: String {
        return displayPrice
    }

    /// Returns the localized price of the product, considering eligibility for an introductory offer.
    ///
    /// - Parameter isEligibleForIntroductoryOffer: A boolean indicating if the user is eligible for an introductory offer.
    /// - Returns: A localized string representation of `price`.
    func localizedPrice(isEligibleForIntroductoryOffer: Bool) -> String {
        guard isEligibleForIntroductoryOffer,
              let introductoryPrice = subscription?.introductoryOffer,
              introductoryPrice.paymentMode != .freeTrial else {
            return localizedPrice
        }

        return introductoryPrice.displayPrice
    }

    /// Returns the locale used for the product's price.
    var priceLocale: Locale {
        return priceFormatStyle.locale
    }

    /// Returns the localized subscription period as a string.
    /// NOTE: Can be empty string if subscription doesn't exist
    var localizedPeriod: String {
        return subscription?.localizedPeriod ?? ""
    }

    /// Returns price per day.
    /// NOTE: Return 0 if it's not a subscription.
    var priceInDay: Decimal {
        guard let periodInDays = subscription?.periodInDays, periodInDays > 0 else { return 0 }
        return price / Decimal(periodInDays)
    }
}

public extension Product.SubscriptionInfo {
    /// Returns the localized subscription period as a string.
    var localizedPeriod: String {
        return subscriptionPeriod.localizedPeriod
    }

    /// Returns the subscription period in days.
    var periodInDays: Int {
        subscriptionPeriod.periodInDays
    }
}

public extension Product.SubscriptionPeriod {
    /// Returns the localized period of the subscription as a string.
    var localizedPeriod: String {
        var localizedPeriod = PeriodFormatter.format(
            unit: unit.toCalendarUnit(),
            numberOfUnits: numberOfUnits)

        let prefix = "1 "

        if let period = localizedPeriod, period.hasPrefix(prefix), numberOfUnits == 1 {
            localizedPeriod = String(period.dropFirst(prefix.count))
        }

        return localizedPeriod?.replacingOccurrences(of: " ", with: "\u{00a0}") ?? ""
    }

    /// Returns the subscription period in days.
    var periodInDays: Int {
        switch unit {
        case .day:
            return 1 * numberOfUnits
        case .week:
            return 7 * numberOfUnits
        case .month:
            return 30 * numberOfUnits
        case .year:
            return 365 * numberOfUnits
        @unknown default:
            fatalError("unknown period")
        }
    }

    /// The number of units that the period represents.
    var numberOfUnits: Int {
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
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            return .day
        }
    }
}

public extension Product.SubscriptionOffer {

    /// Returns the localized price of the subscription offer as a string.
    var localizedPrice: String {
        displayPrice
    }

    /// Returns the localized period of the subscription offer as a string.
    var localizedPeriod: String {
        period.localizedPeriod
    }

    var durationUnits: Int {
        period.numberOfUnits * periodCount
    }

    /// Returns the duration of the subscription offer in units.
    var durationInDays: Int {
        period.periodInDays * periodCount
    }

    /// Returns the duration of the subscription offer in days.
    var localizedDuration: String {
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
    var priceInDay: Decimal {
        guard paymentMode != .freeTrial else {
            return 0
        }

        let periodInDays = period.periodInDays
        return price / Decimal(periodInDays)
    }
}
