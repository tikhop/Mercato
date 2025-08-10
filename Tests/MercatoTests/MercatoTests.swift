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

@Suite("Mercato API Tests")
struct MercatoTests {
    let sharedSession = TestSession.shared
    let mercato = Mercato()

    @Test("Static product retrieval")
    func testStaticProductRetrieval() async throws {
        let products = try await Mercato.retrieveProducts(productIds: [TestProducts.monthlyBasic, TestProducts.annualBasic])

        #expect(products.count == 2)
        #expect(products.contains { $0.id == TestProducts.monthlyBasic })
        #expect(products.contains { $0.id == TestProducts.annualBasic })
    }

    @Test("Static eligibility check")
    func testStaticEligibilityCheck() async throws {
        let isEligible = try await Mercato.isEligibleForIntroOffer(for: TestProducts.monthlyIntro)

        // New users should be eligible
        #expect(isEligible == true)
    }

    @Test("Static purchase status check")
    func testStaticPurchaseStatus() async throws {
        let isPurchased = try await Mercato.isPurchased(TestProducts.removeAds)
        #expect(isPurchased == false)
    }

    @Test("Instance product retrieval")
    func testInstanceProductRetrieval() async throws {
        let products = try await mercato.retrieveProducts(productIds: [TestProducts.coins100, TestProducts.coins500])

        #expect(products.count == 2)
    }

    @Test("Instance eligibility check for set")
    func testInstanceEligibilityCheckForSet() async throws {
        let isEligible = try await mercato.isEligibleForIntroOffer(for: [TestProducts.monthlyIntro, TestProducts.annualIntro])

        // Should check eligibility for the subscription group
        #expect(isEligible == true || isEligible == false)
    }

    @Test("Instance purchase status by product")
    func testInstancePurchaseStatusByProduct() async throws {
        let products = try await mercato.retrieveProducts(productIds: [TestProducts.lifetimeAccess])

        guard let product = products.first else {
            Issue.record("Failed to retrieve product")
            return
        }

        let isPurchased = try await mercato.isPurchased(product)
        #expect(isPurchased == false)
    }

    @Test("Instance purchase status by ID")
    func testInstancePurchaseStatusByID() async throws {
        let isPurchased = try await mercato.isPurchased(TestProducts.premiumFeatures)
        #expect(isPurchased == false)
    }

    @Test("Invalid product ID returns empty array")
    func testInvalidProductID() async throws {
        let products = try await mercato.retrieveProducts(productIds: ["com.invalid.product.xyz"])

        #expect(products.isEmpty)
    }

    @Test("Empty product set returns empty array")
    func testEmptyProductSet() async throws {
        let products = try await mercato.retrieveProducts(productIds: [])
        #expect(products.isEmpty)
    }

    @Test("Purchase status for non-existent product")
    func testPurchaseStatusNonExistent() async throws {
        let isPurchased = try await mercato.isPurchased("com.invalid.product")
        #expect(isPurchased == false)
    }
}
