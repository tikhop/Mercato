//
//  File.swift
//  Mercato
//
//  Created by PT on 8/26/25.
//

import Mercato
import StoreKit

#if canImport(AppKit)
import AppKit

public typealias PurchaseUIContext = NSWindow
#elseif os(iOS)
import UIKit

public typealias PurchaseUIContext = UIViewController
#endif

// MARK: - AdvancedCommerceMercato

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
public final class AdvancedCommerceMercato: Sendable {
    private let acProductService: any AdvancedCommerceProductService
    private let skProductService: any StoreKitProductService

    package convenience init() {
        self.init(
            acProductService: AdvancedCommerceCachingProductService(),
            skProductService: CachingProductService()
        )
    }

    public init(
        acProductService: any AdvancedCommerceProductService,
        skProductService: any StoreKitProductService
    ) {
        self.acProductService = acProductService
        self.skProductService = skProductService
    }

    public func retrieveProducts(productIds: Set<String>) async throws(MercatoError) -> [AdvancedCommerceProduct] {
        try await acProductService.retrieveProducts(productIds: productIds)
    }

    public func allTransactions(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions? {
        await acProductService.allTransactions(for: productId)
    }

    public func currentEntitlements(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions? {
        await acProductService.currentEntitlements(for: productId)
    }

    public func latestTransaction(for productId: AdvancedCommerceProduct.ID) async -> VerificationResult<Transaction>? {
        await acProductService.latestTransaction(for: productId)
    }

    public static let shared = AdvancedCommerceMercato()
}


@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
@MainActor
extension AdvancedCommerceMercato {
    public func purchase(productId: String, advancedCommerceData: Data) async throws -> Product.PurchaseResult {
        guard let product = try await skProductService.retrieveProducts(productIds: [productId]).first else {
            throw MercatoError.productNotFound(productId)
        }

        let options = Product.PurchaseOption.advancedCommerceData(advancedCommerceData)
        return try await product.purchase(options: [options])
    }

    #if !os(watchOS)
    @available(iOS 18.4, macOS 15.4, tvOS 18.4, visionOS 2.4, *)
    @available(watchOS, unavailable)
    public func purchase(
        productId: String,
        compactJWS: String,
        confirmIn view: PurchaseUIContext,
        options: Set<AdvancedCommerceProduct.PurchaseOption> = []
    ) async throws -> AdvancedCommercePurchase {
        guard let product = try await acProductService.retrieveProducts(productIds: [productId]).first else {
            throw MercatoError.productNotFound(productId)
        }

        do {
            let result = try await product.purchase(compactJWS: compactJWS, confirmIn: view, options: options)

            return try await handlePurchaseResult(
                result,
                product: product,
                finishAutomatically: false
            )
        } catch {
            throw MercatoError.wrapped(error: error)
        }
    }
    #endif

    #if os(watchOS)
    @available(watchOS 11.4, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    public func purchase(
        productId: String,
        compactJWS: String,
        options: Set<AdvancedCommerceProduct.PurchaseOption> = []
    ) async throws -> AdvancedCommercePurchase {
        guard let product = try await productService.retrieveProducts(productIds: [productId]).first else {
            throw MercatoError.productNotFound(productId)
        }

        do {
            let result = try await product.purchase(compactJWS: compactJWS, options: options)

            return try await handlePurchaseResult(
                result,
                product: product,
                finishAutomatically: false
            )
        } catch {
            throw MercatoError.wrapped(error: error)
        }
    }
    #endif

    private func handlePurchaseResult(
        _ result: Product.PurchaseResult,
        product: AdvancedCommerceProduct,
        finishAutomatically: Bool
    ) async throws(MercatoError) -> AdvancedCommercePurchase {
        switch result {
        case .success(let verification):
            let transaction = try verification.payload

            if finishAutomatically {
                await transaction.finish()
            }

            return AdvancedCommercePurchase(
                product: product,
                result: verification,
                needsFinishTransaction: !finishAutomatically
            )
        case .userCancelled:
            throw MercatoError.canceledByUser
        case .pending:
            throw MercatoError.purchaseIsPending
        @unknown default:
            throw MercatoError.unknown(error: nil)
        }
    }
}

@available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *)
extension AdvancedCommerceMercato {
    public static func purchase(productId: String, advancedCommerceData: Data) async throws -> Product.PurchaseResult {
        try await shared.purchase(productId: productId, advancedCommerceData: advancedCommerceData)
    }

    #if !os(watchOS)
    @available(iOS 18.4, macOS 15.4, tvOS 18.4, visionOS 2.4, *)
    @available(watchOS, unavailable)
    public static func purchase(
        productId: String,
        compactJWS: String,
        confirmIn view: PurchaseUIContext,
        options: Set<AdvancedCommerceProduct.PurchaseOption> = []
    ) async throws -> AdvancedCommercePurchase {
        try await shared.purchase(productId: productId, compactJWS: compactJWS, confirmIn: view, options: options)
    }
    #endif

    #if os(watchOS)
    @available(watchOS 11.4, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    public static func purchase(
        productId: String,
        compactJWS: String,
        options: Set<AdvancedCommerceProduct.PurchaseOption> = []
    ) async throws -> AdvancedCommercePurchase {
        try await shared.purchase(productId: productId, compactJWS: compactJWS, options: options)
    }

    #endif

    public static func allTransactions(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions? {
        await shared.allTransactions(for: productId)
    }

    public static func currentEntitlements(for productId: AdvancedCommerceProduct.ID) async -> Transaction.Transactions? {
        await shared.currentEntitlements(for: productId)
    }

    public static func latestTransaction(for productId: AdvancedCommerceProduct.ID) async -> VerificationResult<Transaction>? {
        await shared.latestTransaction(for: productId)
    }
}
