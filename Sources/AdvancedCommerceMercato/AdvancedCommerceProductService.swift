//
//  File.swift
//  Mercato
//
//  Created by PT on 8/26/25.
//

import Foundation
import Mercato
import StoreKit

// MARK: - AdvancedCommerceProductService

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
public protocol AdvancedCommerceProductService: ProductService where ProductItem == AdvancedCommerceProduct {
    func latestTransaction(for productId: AdvancedCommerceProduct.ID) async -> VerificationResult<Transaction>?
    func allTransactions(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions?
    func currentEntitlements(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions?
}

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
public typealias AdvancedCommerceCachingProductService = AbstractCachingProductService<AdvancedCommerceProduct>

// MARK: - AdvancedCommerceCachingProductService + AdvancedCommerceProductService

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
extension AdvancedCommerceCachingProductService: AdvancedCommerceProductService {
    public func latestTransaction(for productId: AdvancedCommerceProduct.ID) async -> VerificationResult<Transaction>? {
        guard let product = try? await retrieveProducts(productIds: [productId]).first else {
            return nil
        }

        return await product.latestTransaction
    }

    public func allTransactions(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions? {
        guard let product = try? await retrieveProducts(productIds: [productId]).first else {
            return nil
        }

        return product.allTransactions
    }

    public func currentEntitlements(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions? {
        guard let product = try? await retrieveProducts(productIds: [productId]).first else {
            return nil
        }

        return product.currentEntitlements
    }
}

// MARK: - AdvancedCommerceProduct + FetchableProduct

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
extension AdvancedCommerceProduct: FetchableProduct {
    public static func products(for identifiers: some Collection<String>) async throws -> [AdvancedCommerceProduct] {
        try await withThrowingTaskGroup(of: AdvancedCommerceProduct.self) { group in
            for id in identifiers {
                group.addTask {
                    try await AdvancedCommerceProduct(id: id)
                }
            }

            var products: [AdvancedCommerceProduct] = []
            for try await product in group {
                products.append(product)
            }

            return products
        }
    }
}
