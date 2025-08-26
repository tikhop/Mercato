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
    associatedtype ProductItem
    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `MercatoError`
    ///
    func retrieveProducts(productIds: Set<String>) async throws(MercatoError) -> [ProductItem]

}


// MARK: - StoreKitProductService

public protocol StoreKitProductService: ProductService where ProductItem == StoreKit.Product {
    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    func isPurchased(_ product: StoreKit.Product) async throws(MercatoError) -> Bool

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    func isPurchased(_ productIdentifier: String) async throws(MercatoError) -> Bool
}


// MARK: - FetchableProduct

public protocol FetchableProduct {
    var id: String { get }

    static func products(for identifiers: some Collection<String>) async throws -> [Self]
}

// MARK: - AbstractCachingProductService

public class AbstractCachingProductService<P: Sendable & FetchableProduct>: ProductService, @unchecked Sendable {
    public typealias ProductItem = P

    internal let lock = DefaultLock()
    internal var cachedProducts: [String: ProductItem] = [:]
    internal var activeFetches: [Set<String>: Task<[ProductItem], Error>] = [:]

    public init() { }

    public func retrieveProducts(productIds: Set<String>) async throws(MercatoError) -> [ProductItem] {
        lock.lock()
        let cachedProducts = cachedProducts
        lock.unlock()

        var cached: [ProductItem] = []
        var missingIds = Set<String>()

        for id in productIds {
            if let product = cachedProducts[id] {
                cached.append(product)
            } else {
                missingIds.insert(id)
            }
        }

        if missingIds.isEmpty {
            return cached
        }

        return try await fetchProducts(productIds: missingIds) + cached
    }

    internal func fetchProducts(productIds: Set<String>) async throws(MercatoError) -> [ProductItem] {
        lock.lock()
        if let existingTask = activeFetches[productIds] {
            lock.unlock()
            do {
                let fetchedProducts = try await existingTask.value
                return fetchedProducts
            } catch {
                throw MercatoError.wrapped(error: error)
            }
        }

        let fetchTask = Task<[ProductItem], Error> {
            try await ProductItem.products(for: productIds)
        }
        activeFetches[productIds] = fetchTask
        lock.unlock()

        do {
            let fetchedProducts = try await fetchTask.value

            lock.lock()
            for product in fetchedProducts {
                cachedProducts[product.id] = product
            }
            activeFetches.removeValue(forKey: productIds)
            lock.unlock()

            return fetchedProducts
        } catch {
            lock.lock()
            activeFetches.removeValue(forKey: productIds)
            lock.unlock()

            throw MercatoError.wrapped(error: error)
        }
    }
}

extension AbstractCachingProductService where ProductItem == StoreKit.Product {
    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public nonisolated func isPurchased(_ product: Product) async throws(MercatoError) -> Bool {
        try await isPurchased(product.id)
    }

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public nonisolated func isPurchased(_ productIdentifier: String) async throws(MercatoError) -> Bool {
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

public typealias CachingProductService = AbstractCachingProductService<StoreKit.Product>
extension CachingProductService: StoreKitProductService { }
extension StoreKit.Product: FetchableProduct { }
