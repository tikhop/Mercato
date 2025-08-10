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

import StoreKit
import StoreKitTest
import Testing
@testable import Mercato

@Suite("Product Extensions Tests")
struct ProductTests {
    let mercato = Mercato()
    let session = TestSession.shared

    @Test("Regular monthly subscription properties")
    func testRegularMonthlySubscription() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyBasic])

        guard let product = products.first else {
            Issue.record("Failed to retrieve monthly product")
            return
        }

        let subscription = product.subscription
        #expect(subscription != nil)

        let isEligible = await product.isEligibleForIntroOffer
        let hasActiveSubscription = await product.hasActiveSubscription

        #expect(isEligible == true)
        #expect(hasActiveSubscription == false)
        #expect(product.hasIntroductoryOffer == false)
        #expect(product.hasTrial == false)
        #expect(product.hasPayAsYouGoOffer == false)

        // Price checks
        #expect(product.price == Decimal.testPrice299)
        #expect(product.displayPrice == "$2.99")
        #expect(subscription?.subscriptionPeriod.value == 1)
        #expect(subscription?.subscriptionPeriod.unit == .month)
        #expect(subscription?.subscriptionPeriod.periodInDays == 30)
    }

    @Test("Annual subscription properties")
    func testAnnualSubscription() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.annualBasic])

        guard let product = products.first else {
            Issue.record("Failed to retrieve annual product")
            return
        }

        #expect(product.subscription != nil)
        #expect(product.price == Decimal.testPrice2999)
        #expect(product.subscription?.subscriptionPeriod.unit == .year)
        #expect(product.subscription?.subscriptionPeriod.periodInDays == 365)
    }

    @Test("Monthly subscription with trial")
    func testMonthlyTrialSubscription() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyTrial])

        guard let product = products.first else {
            Issue.record("Failed to retrieve monthly trial product")
            return
        }


        #expect(product.hasIntroductoryOffer == true)
        #expect(product.hasTrial == true)
        #expect(product.hasPayAsYouGoOffer == false)

        let introOffer = product.subscription?.introductoryOffer
        #expect(introOffer != nil)
        #expect(introOffer?.paymentMode == .freeTrial)
        #expect(introOffer?.period.unit == .week)
        #expect(introOffer?.period.value == 1)
    }

    @Test("Annual subscription with trial")
    func testAnnualTrialSubscription() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.annualTrial])

        guard let product = products.first else {
            Issue.record("Failed to retrieve annual trial product")
            return
        }

        #expect(product.hasTrial == true)

        let introOffer = product.subscription?.introductoryOffer
        #expect(introOffer?.paymentMode == .freeTrial)
        #expect(introOffer?.period.unit == .month)
        #expect(introOffer?.period.value == 1)
    }

    @Test("Monthly subscription with intro price")
    func testMonthlyIntroSubscription() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyIntro])

        guard let product = products.first else {
            Issue.record("Failed to retrieve monthly intro product")
            return
        }

        #expect(product.hasIntroductoryOffer == true)
        #expect(product.hasTrial == false)
        #expect(product.hasPayAsYouGoOffer == true)

        let introOffer = product.subscription?.introductoryOffer
        #expect(introOffer != nil)
        #expect(introOffer?.paymentMode == .payAsYouGo)
        #expect(introOffer?.price == Decimal.testPrice099)
        #expect(introOffer?.periodCount == 3)

        // Test intro price calculation
        let introDurationDays = introOffer?.durationInDays ?? 0
        #expect(introDurationDays == 90) // 3 months * 30 days
    }

    @Test("Price per day calculation")
    func testPricePerDay() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyBasic])

        guard let product = products.first else {
            Issue.record("Failed to retrieve product")
            return
        }

        let pricePerDay = product.priceInDay
        let expectedPricePerDay = Decimal.testPrice299 / 30

        // Allow small difference due to decimal precision
        let difference = abs(pricePerDay - expectedPricePerDay)
        #expect(difference < Decimal(0.01))
    }

    @Test("Localized price with intro offer")
    func testLocalizedPriceWithIntroOffer() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyIntro])

        guard let product = products.first else {
            Issue.record("Failed to retrieve product")
            return
        }

        // When eligible for intro offer
        let introPrice = product.price(isEligibleForIntroductoryOffer: true)
        #expect(introPrice == Decimal.testPrice099)

        // When not eligible
        let regularPrice = product.price(isEligibleForIntroductoryOffer: false)
        #expect(regularPrice == product.price)
    }

    @Test("Final price with free trial")
    func testFinalPriceWithFreeTrial() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyTrial])

        guard let product = products.first else {
            Issue.record("Failed to retrieve product")
            return
        }

        // Free trial should have final price of 0
        let finalPrice = product.finalPrice(isEligibleForIntroductoryOffer: true)
        #expect(finalPrice == Decimal(0))

        // Without eligibility, should return regular price
        let regularPrice = product.finalPrice(isEligibleForIntroductoryOffer: false)
        #expect(regularPrice == product.price)
    }

    @Test("Consumable product properties")
    func testConsumableProduct() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.coins100])

        guard let product = products.first else {
            Issue.record("Failed to retrieve consumable product")
            return
        }

        #expect(product.type == .consumable)
        #expect(product.subscription == nil)
        #expect(product.hasIntroductoryOffer == false)
        #expect(product.localizedPeriod == "")
        #expect(product.priceInDay == Decimal(0))
    }

    @Test("Non-consumable product properties")
    func testNonConsumableProduct() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.removeAds])

        guard let product = products.first else {
            Issue.record("Failed to retrieve non-consumable product")
            return
        }

        #expect(product.type == .nonConsumable)
        #expect(product.isFamilyShareable == true)
        #expect(product.subscription == nil)
    }

    @Test("Non-renewing subscription properties")
    func testNonRenewingSubscription() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.nonRenewingMonth])

        guard let product = products.first else {
            Issue.record("Failed to retrieve non-renewing subscription")
            return
        }

        #expect(product.type == .nonRenewable)
        #expect(product.subscription == nil)
        #expect(product.hasIntroductoryOffer == false)
    }

    @Test("Localized period formatting")
    func testLocalizedPeriod() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [
            TestProducts.weeklyBasic,
            TestProducts.monthlyBasic,
            TestProducts.annualBasic
        ])

        for product in products {
            let period = product.localizedPeriod
            #expect(!period.isEmpty)

            // Check non-breaking space is used
            #expect(period.contains("\u{00a0}") || !period.contains(" "))
        }
    }

    @Test("Localized duration for intro offers")
    func testLocalizedDuration() async throws {
        let products = try await mercato.retrieveSubscriptionProducts(productIds: [TestProducts.monthlyIntro])

        guard let product = products.first,
              let introOffer = product.subscription?.introductoryOffer else {
            Issue.record("Failed to retrieve intro offer")
            return
        }

        let duration = introOffer.localizedDuration
        #expect(!duration.isEmpty)
        #expect(duration.contains("3") || duration.contains("three"))
    }
}
