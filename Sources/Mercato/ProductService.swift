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

// MARK: - ProductService

public protocol ProductService: Sendable {
    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `MercatoError`
    ///
    func retrieveProducts(productIds: Set<String>) async throws (MercatoError) -> [Product]

    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    func isPurchased(_ product: Product) async throws (MercatoError) -> Bool

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    func isPurchased(_ productIdentifier: String) async throws (MercatoError) -> Bool
}

/// A product service implementation with caching and request deduplication
package final class CachingProductService: ProductService, @unchecked Sendable {
    private let lock = DefaultLock()
    private var cachedProducts: [String: Product] = [:]
    private var activeFetches: [Set<String>: Task<[Product], Error>] = [:]

    public func retrieveProducts(productIds: Set<String>) async throws (MercatoError) -> [Product] {
        lock.lock()
        var cached: [Product] = []
        var missingIds = Set<String>()

        for id in productIds {
            if let product = cachedProducts[id] {
                cached.append(product)
            } else {
                missingIds.insert(id)
            }
        }

        if missingIds.isEmpty {
            lock.unlock()
            return cached
        }

        if let existingTask = activeFetches[missingIds] {
            lock.unlock()
            do {
                let fetchedProducts = try await existingTask.value
                return cached + fetchedProducts
            } catch {
                throw MercatoError.wrapped(error: error)
            }
        }

        let fetchTask = Task<[Product], Error> {
            try await Product.products(for: missingIds)
        }
        activeFetches[missingIds] = fetchTask
        lock.unlock()

        do {
            let fetchedProducts = try await fetchTask.value

            lock.lock()
            for product in fetchedProducts {
                cachedProducts[product.id] = product
            }
            activeFetches.removeValue(forKey: missingIds)
            lock.unlock()

            return cached + fetchedProducts
        } catch {
            lock.lock()
            activeFetches.removeValue(forKey: missingIds)
            lock.unlock()
            throw MercatoError.wrapped(error: error)
        }
    }

    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public nonisolated func isPurchased(_ product: Product) async throws (MercatoError) -> Bool {
        try await isPurchased(product.id)
    }

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public nonisolated func isPurchased(_ productIdentifier: String) async throws (MercatoError) -> Bool {
        guard let result = await Transaction.latest(for: productIdentifier) else {
            return false
        }

        do {
            let tx = try result.payloadValue
            return tx.revocationDate == nil && !tx.isUpgraded
        } catch {
            throw MercatoError.wrapped(error: error)
        }
    }
}


