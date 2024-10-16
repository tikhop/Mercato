import StoreKit

public protocol ProductFetcher: Sendable {
    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `StoreKitError`
    ///
    func retrieveProducts(productIds: Set<String>) async throws -> [Product]
}

/// An actor that provides methods to work with `Product`s
actor BaseProductFetcher: ProductFetcher {
    private var cachedProducts: Set<Product> = []

    public func retrieveProducts(productIds: Set<String>) async throws -> [Product] {
        let (cachedItems, missedProductIds) = retrieveFromCachedProducts(cachedProducts, productIds: productIds)

        guard cachedItems.count != productIds.count else {
            return Array(cachedItems)
        }

        do {
            let products = try await Product.products(for: missedProductIds)
            let allProducts = cachedItems + products

            cachedProducts = cachedProducts.union(Set(products))

            return allProducts
        } catch {
            throw error
        }
    }

    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: An error if the purchase status could not be determined.
    public func isPurchased(_ product: Product) async throws -> Bool {
        try await isPurchased(product.id)
    }

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: An error if the purchase status could not be determined.
    public func isPurchased(_ productIdentifier: String) async throws -> Bool {
        guard let result = await Transaction.latest(for: productIdentifier) else {
            return false
        }

        let tx = try result.payloadValue

        return tx.revocationDate == nil && !tx.isUpgraded
    }
}

internal extension BaseProductFetcher {

    /// Retrieves products from the cache.
    ///
    /// - Parameters:
    ///   - cachedProducts: The set of cached products.
    ///   - productIds: The set of product identifiers to retrieve.
    /// - Returns: A tuple containing an array of cached products and an array of missed product IDs.
    func retrieveFromCachedProducts(
        _ cachedProducts: Set<Product>,
        productIds: Set<String>
    ) -> (result: Set<Product>, missedProducts: Set<String>) {
        guard !cachedProducts.isEmpty else {
            return ([], productIds)
        }

        var result: Set<Product> = []
        var missedProducts: Set<String> = productIds

        for item in cachedProducts {
            let productId = item.id

            if missedProducts.contains(productId) {
                result.insert(item)
                missedProducts.remove(item.id)
            }
        }

        return (result, missedProducts)
    }
}

