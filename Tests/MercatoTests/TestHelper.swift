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
import StoreKitTest
import Testing
@testable import Mercato

// MARK: - TestProducts

enum TestProducts {
    // Consumables
    static let coins100 = "com.mercato.tests.consumable.coins.100"
    static let coins500 = "com.mercato.tests.consumable.coins.500"
    static let coins1000 = "com.mercato.tests.consumable.coins.1000"
    static let extraLife = "com.mercato.tests.consumable.life"

    // Non-Consumables
    static let removeAds = "com.mercato.tests.nonconsumable.removeads"
    static let premiumFeatures = "com.mercato.tests.nonconsumable.premium"
    static let lifetimeAccess = "com.mercato.tests.nonconsumable.lifetime"

    // Non-Renewing Subscriptions
    static let nonRenewingMonth = "com.mercato.tests.nonrenewing.month"
    static let nonRenewingYear = "com.mercato.tests.nonrenewing.year"

    // Basic Subscriptions
    static let weeklyBasic = "com.mercato.tests.subscription.weekly"
    static let monthlyBasic = "com.mercato.tests.subscription.monthly"
    static let annualBasic = "com.mercato.tests.subscription.annual"

    // Trial Subscriptions
    static let weeklyTrial = "com.mercato.tests.subscription.weekly.trial"
    static let monthlyTrial = "com.mercato.tests.subscription.monthly.trial"
    static let annualTrial = "com.mercato.tests.subscription.annual.trial"

    // Intro Offer Subscriptions
    static let monthlyIntro = "com.mercato.tests.subscription.monthly.intro"
    static let annualIntro = "com.mercato.tests.subscription.annual.intro"

    // Premium Subscriptions
    static let premiumMonthly = "com.mercato.tests.subscription.premium.monthly"
    static let premiumAnnual = "com.mercato.tests.subscription.premium.annual"
}

// MARK: - TestSession

final class TestSession: @unchecked Sendable {
    let session: SKTestSession

    init() {
        let url = Bundle.module.url(forResource: "Mercato", withExtension: "storekit")!
        session = try! SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
    }

    func clearAllTransactions() {
        session.clearTransactions()
    }

    func expireSubscription(for productID: String) throws {
        try session.expireSubscription(productIdentifier: productID)
    }

    func forceRenewalOfSubscription(for productID: String) throws {
        try session.forceRenewalOfSubscription(productIdentifier: productID)
    }

    func refundTransaction(identifier: UInt) throws {
        try session.refundTransaction(identifier: identifier)
    }

    func setAskToBuyEnabled(_ enabled: Bool) {
        session.askToBuyEnabled = enabled
    }

    @available(iOS 17.0, *)
    func buy(productID: String) async throws {
        try await session.buyProduct(identifier: TestProducts.monthlyBasic)
    }

    public static let shared = TestSession()
}

// MARK: - MercatoAssertions

enum MercatoAssertions {

    static func assertProductAvailable(_ productID: String, in products: [Product]) {
        #expect(products.contains { $0.id == productID }, "Product \(productID) should be available")
    }

    static func assertSubscriptionHasTrial(_ product: Product) {
        #expect(product.hasTrial == true, "Product \(product.id) should have a trial")
    }

    static func assertSubscriptionHasIntroOffer(_ product: Product) {
        #expect(product.hasIntroductoryOffer == true, "Product \(product.id) should have an intro offer")
    }

    static func assertPriceEquals(_ product: Product, expectedPrice: Decimal) {
        #expect(product.price == expectedPrice, "Product \(product.id) price should be \(expectedPrice)")
    }

    static func assertPurchaseSucceeded(_ purchase: Purchase) {
        #expect(purchase.productId == purchase.product.id, "Purchase product ID should match")
        #expect(purchase.quantity > 0, "Purchase quantity should be greater than 0")
    }
}

// MARK: - Test Utilities

extension Decimal {
    /// Common test prices
    static let testPrice099 = Decimal(0.99)
    static let testPrice199 = Decimal(1.99)
    static let testPrice299 = Decimal(2.99)
    static let testPrice499 = Decimal(4.99)
    static let testPrice999 = Decimal(9.99)
    static let testPrice1999 = Decimal(19.99)
    static let testPrice2999 = Decimal(29.99)
    static let testPrice4999 = Decimal(49.99)
    static let testPrice5999 = Decimal(59.99)
    static let testPrice9999 = Decimal(99.99)
}

// MARK: - Locale Testing

extension Locale {
    static let testUS = Locale(identifier: "en_US")
    static let testUK = Locale(identifier: "en_GB")
    static let testFR = Locale(identifier: "fr_FR")
    static let testDE = Locale(identifier: "de_DE")
    static let testJP = Locale(identifier: "ja_JP")
}

// MARK: - TestCurrencies

enum TestCurrencies {
    static let usd = "USD"
    static let eur = "EUR"
    static let gbp = "GBP"
    static let jpy = "JPY"
    static let cad = "CAD"
    static let aud = "AUD"
}
