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

@Suite("ProductService Tests")
struct ProductServiceTests {
    let session = TestSession.shared
    let productService = CachingProductService()
    let mercato = Mercato()

    @Test("Retrieves single product successfully")
    func testRetrieveSingleProduct() async throws {
        let products = try await productService.retrieveProducts(productIds: [TestProducts.monthlyBasic])

        #expect(products.count == 1)
        #expect(products.first?.id == TestProducts.monthlyBasic)
    }

    @Test("Retrieves multiple products")
    func testRetrieveMultipleProducts() async throws {
        let productIds = Set([
            TestProducts.monthlyBasic,
            TestProducts.annualBasic,
            TestProducts.weeklyBasic
        ])

        let products = try await productService.retrieveProducts(productIds: productIds)

        #expect(products.count == 3)
        #expect(products.contains { $0.id == TestProducts.monthlyBasic })
        #expect(products.contains { $0.id == TestProducts.annualBasic })
        #expect(products.contains { $0.id == TestProducts.weeklyBasic })
    }

    @Test("Returns empty array for non-existent products")
    func testNonExistentProducts() async throws {
        let products = try await productService.retrieveProducts(productIds: ["com.nonexistent.product"])

        #expect(products.isEmpty)
    }

    @Test("Uses cache for repeated requests")
    func testCacheUsage() async throws {
        let productIds = Set([TestProducts.monthlyBasic, TestProducts.annualBasic])

        // First retrieval - fetches from StoreKit
        let firstProducts = try await productService.retrieveProducts(productIds: productIds)
        #expect(firstProducts.count == 2)

        // Second retrieval - should use cache
        let secondProducts = try await productService.retrieveProducts(productIds: productIds)
        #expect(secondProducts.count == 2)

        // Products should be identical
        #expect(Set(firstProducts.map { $0.id }) == Set(secondProducts.map { $0.id }))
    }

    @Test("Handles partial cache hits")
    func testPartialCacheHit() async throws {
        // First, cache some products
        let initialProducts = Set([TestProducts.monthlyBasic])
        _ = try await productService.retrieveProducts(productIds: initialProducts)

        // Now request both cached and uncached products
        let mixedProducts = Set([
            TestProducts.monthlyBasic, // cached
            TestProducts.annualBasic // not cached
        ])

        let products = try await productService.retrieveProducts(productIds: mixedProducts)
        #expect(products.count == 2)
        #expect(products.contains { $0.id == TestProducts.monthlyBasic })
        #expect(products.contains { $0.id == TestProducts.annualBasic })
    }

    @Test("Reports product as not purchased initially")
    func testProductNotPurchased() async throws {
        let isPurchased = try await productService.isPurchased(TestProducts.removeAds)
        #expect(isPurchased == false)
    }

    @Test("Checks purchase status by Product object")
    func testPurchaseStatusByProduct() async throws {
        let products = try await productService.retrieveProducts(productIds: [TestProducts.premiumFeatures])

        guard let product = products.first else {
            Issue.record("Failed to retrieve product")
            return
        }

        let isPurchased = try await productService.isPurchased(product)
        #expect(isPurchased == false)
    }

    @Test("Handles empty product ID set")
    func testEmptyProductSet() async throws {
        let productService = CachingProductService()
        let products = try await productService.retrieveProducts(productIds: [])
        #expect(products.isEmpty)
    }

    @Test("Handles concurrent requests for same products")
    func testConcurrentRequests() async throws {
        let productService = CachingProductService()
        let productIds = Set([TestProducts.monthlyBasic])

        // Launch multiple concurrent requests
        async let products1 = productService.retrieveProducts(productIds: productIds)
        async let products2 = productService.retrieveProducts(productIds: productIds)
        async let products3 = productService.retrieveProducts(productIds: productIds)

        let results = try await [products1, products2, products3]

        // All should succeed and return the same product
        for result in results {
            #expect(result.count == 1)
            #expect(result.first?.id == TestProducts.monthlyBasic)
        }
    }
}
