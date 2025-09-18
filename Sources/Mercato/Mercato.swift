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

#if canImport(AppKit)
import AppKit

public typealias DisplayContext = NSViewController
#elseif os(iOS)
import class UIKit.UIWindowScene

public typealias DisplayContext = UIWindowScene
#endif

// MARK: - Mercato.PurchaseOptionsBuilder

extension Mercato {

    /// A builder class for constructing a set of purchase options for a product.
    public class PurchaseOptionsBuilder {
        /// The quantity of the product to purchase.
        var quantity = 1

        /// An optional promotional offer to apply to the purchase.
        var promotionalOffer: PromotionalOffer? = nil

        /// An optional app account token to associate with the purchase.
        var appAccountToken: UUID? = nil

        /// A flag indicating whether to simulate "Ask to Buy" in the sandbox environment.
        var simulatesAskToBuyInSandbox = false

        public init(
            quantity: Int,
            promotionalOffer: PromotionalOffer? = nil,
            appAccountToken: UUID? = nil,
            simulatesAskToBuyInSandbox: Bool
        ) {
            self.quantity = quantity
            self.promotionalOffer = promotionalOffer
            self.appAccountToken = appAccountToken
            self.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox
        }

        public init() { }

        /// Sets the quantity of the product to purchase.
        ///
        /// - Parameter quantity: The quantity to set.
        /// - Returns: The updated `PurchaseOptionsBuilder` instance.
        public func setQuantity(_ quantity: Int) -> Mercato.PurchaseOptionsBuilder {
            self.quantity = quantity

            return self
        }

        /// Sets the promotional offer to apply to the purchase.
        ///
        /// - Parameter promotionalOffer: The promotional offer to set.
        /// - Returns: The updated `PurchaseOptionsBuilder` instance.
        public func setPromotionalOffer(_ promotionalOffer: Mercato.PromotionalOffer?) -> Mercato.PurchaseOptionsBuilder {
            self.promotionalOffer = promotionalOffer

            return self
        }

        /// Sets the app account token to associate with the purchase.
        ///
        /// - Parameter appAccountToken: The app account token to set.
        /// - Returns: The updated `PurchaseOptionsBuilder` instance.
        public func setAppAccountToken(_ appAccountToken: UUID?) -> Mercato.PurchaseOptionsBuilder {
            self.appAccountToken = appAccountToken

            return self
        }

        /// Sets whether to simulate "Ask to Buy" in the sandbox environment.
        ///
        /// - Parameter simulatesAskToBuyInSandbox: A flag indicating whether to simulate "Ask to Buy".
        /// - Returns: The updated `PurchaseOptionsBuilder` instance.
        public func setSimulatesAskToBuyInSandbox(_ simulatesAskToBuyInSandbox: Bool) -> Mercato.PurchaseOptionsBuilder {
            self.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox

            return self
        }

        /// Builds and returns the set of purchase options.
        ///
        /// - Returns: A set of `Product.PurchaseOption` containing the configured options.
        public func build() -> Set<Product.PurchaseOption> {
            var options: Set<Product.PurchaseOption> = []
            options.insert(Product.PurchaseOption.quantity(quantity))
            options.insert(Product.PurchaseOption.simulatesAskToBuyInSandbox(simulatesAskToBuyInSandbox))

            if let appAccountToken {
                options.insert(Product.PurchaseOption.appAccountToken(appAccountToken))
            }

            if let promotionalOffer {
                let option = Product.PurchaseOption.promotionalOffer(
                    offerID: promotionalOffer.offerID,
                    keyID: promotionalOffer.keyID,
                    nonce: promotionalOffer.nonce,
                    signature: promotionalOffer.signature,
                    timestamp: promotionalOffer.timestamp
                )

                options.insert(option)
            }

            return options
        }
    }
}

// MARK: - Mercato

public final class Mercato: Sendable {
    private let productService: any StoreKitProductService

    public convenience init() {
        self.init(productService: CachingProductService())
    }

    public init(productService: any StoreKitProductService) {
        self.productService = productService
    }

    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `MercatoError`
    public func retrieveProducts(productIds: Set<String>) async throws(MercatoError) -> [Product] {
        try await productService.retrieveProducts(productIds: productIds)
    }

    /// Requests subscription product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `MercatoError`
    public func retrieveSubscriptionProducts(productIds: Set<String>) async throws(MercatoError) -> [Product] {
        try await productService.retrieveProducts(productIds: productIds)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productIds: Set of product ids.
    public func isEligibleForIntroOffer(for productIds: Set<String>) async throws(MercatoError) -> Bool {
        let products = try await productService.retrieveProducts(productIds: productIds)

        guard let product = products.first else {
            throw MercatoError.purchase(error: .productUnavailable)
        }

        guard let subscription = product.subscription else {
            return false
        }

        let subscriptionGroupID = subscription.subscriptionGroupID

        return await Product.SubscriptionInfo.isEligibleForIntroOffer(for: subscriptionGroupID)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productId: The product identifier to check eligibility for.
    public func isEligibleForIntroOffer(for productId: String) async throws(MercatoError) -> Bool {
        let products = try await productService.retrieveProducts(productIds: [productId])

        guard let product = products.first else {
            throw MercatoError.purchase(error: .productUnavailable)
        }

        return await isEligibleForIntroOffer(for: product)
    }

    private func isEligibleForIntroOffer(for product: Product) async -> Bool {
        await product.subscription?.isEligibleForIntroOffer ?? false
    }

    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public func isPurchased(_ product: Product) async throws(MercatoError) -> Bool {
        try await productService.isPurchased(product)
    }

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public func isPurchased(_ productIdentifier: String) async throws(MercatoError) -> Bool {
        try await productService.isPurchased(productIdentifier)
    }

    // MARK: - Subscription Status

    /// Checks if a subscription is in billing retry state
    /// - Parameter productId: The product identifier to check
    /// - Returns: True if the subscription is in billing retry, false otherwise
    public func isInBillingRetry(for productId: String) async -> Bool {
        do {
            let products = try await productService.retrieveProducts(productIds: [productId])
            guard let product = products.first,
                  let subscription = product.subscription else {
                return false
            }

            let statuses = try await subscription.status
            guard let status = statuses.first else { return false }

            return status.state == .inBillingRetryPeriod
        } catch {
            return false
        }
    }

    /// Checks if a subscription is in grace period
    /// - Parameter productId: The product identifier to check
    /// - Returns: True if the subscription is in grace period, false otherwise
    public func isInGracePeriod(for productId: String) async -> Bool {
        do {
            let products = try await productService.retrieveProducts(productIds: [productId])
            guard let product = products.first,
                  let subscription = product.subscription else {
                return false
            }

            let statuses = try await subscription.status
            guard let status = statuses.first else { return false }

            return status.state == .inGracePeriod
        } catch {
            return false
        }
    }

    /// Gets the current renewal state for a subscription
    /// - Parameter productId: The product identifier to check
    /// - Returns: The renewal state or nil if not a subscription
    public func renewalState(for productId: String) async -> Product.SubscriptionInfo.RenewalState? {
        do {
            let products = try await productService.retrieveProducts(productIds: [productId])
            guard let product = products.first,
                  let subscription = product.subscription else {
                return nil
            }

            let statuses = try await subscription.status
            return statuses.first?.state
        } catch {
            return nil
        }
    }

}

// MARK: - Mercato: Purchase

extension Mercato {
    /// Initiates a purchase for a specified productId with optional parameters.
    ///
    /// - Parameters:
    ///   - productIs: The product id.
    ///   - promotionalOffer: An optional promotional offer to apply.
    ///   - quantity: The quantity of the product to purchase. Default is 1.
    ///   - finishAutomatically: A flag indicating whether the transaction should be finished automatically. Default is true.
    ///   - appAccountToken: An optional app account token to associate with the purchase.
    ///   - simulatesAskToBuyInSandbox: A flag indicating whether to simulate "Ask to Buy" in the sandbox environment. Default is false.
    /// - Returns: A `Purchase` object representing the completed purchase.
    /// - Throws: `MercatoError` if the purchase fails.
    @discardableResult
    public func purchase(
        productId: String,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws(MercatoError) -> Purchase {
        let products = try await productService.retrieveProducts(productIds: [productId])

        guard let product = products.first else {
            throw MercatoError.purchase(error: .productUnavailable)
        }

        return try await purchase(
            product: product,
            promotionalOffer: promotionalOffer,
            quantity: quantity,
            finishAutomatically: finishAutomatically,
            simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox
        )
    }

    /// Initiates a purchase for a specified product with optional parameters.
    ///
    /// - Parameters:
    ///   - product: The product to be purchased.
    ///   - promotionalOffer: An optional promotional offer to apply.
    ///   - quantity: The quantity of the product to purchase. Default is 1.
    ///   - finishAutomatically: A flag indicating whether the transaction should be finished automatically. Default is true.
    ///   - appAccountToken: An optional app account token to associate with the purchase.
    ///   - simulatesAskToBuyInSandbox: A flag indicating whether to simulate "Ask to Buy" in the sandbox environment. Default is false.
    /// - Returns: A `Purchase` object representing the completed purchase.
    /// - Throws: `MercatoError` if the purchase fails.
    @discardableResult
    public func purchase(
        product: Product,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws(MercatoError) -> Purchase {
        let options = PurchaseOptionsBuilder()
            .setQuantity(quantity)
            .setAppAccountToken(appAccountToken)
            .setSimulatesAskToBuyInSandbox(simulatesAskToBuyInSandbox)
            .setPromotionalOffer(promotionalOffer)
            .build()

        return try await purchase(product: product, options: options, finishAutomatically: finishAutomatically)
    }

    /// Initiates a purchase for a specified product with specific purchase options.
    ///
    /// - Parameters:
    ///   - product: The product to be purchased.
    ///   - options: A set of `Product.PurchaseOption` specifying the purchase options.
    ///   - finishAutomatically: A flag indicating whether the transaction should be finished automatically.
    /// - Returns: A `Purchase` object representing the completed purchase.
    /// - Throws: `MercatoError` if the purchase fails.
    @discardableResult
    public func purchase(
        product: Product,
        options: Set<Product.PurchaseOption>,
        finishAutomatically: Bool
    ) async throws(MercatoError) -> Purchase {
        do {
            let result = try await product.purchase(options: options)

            return try await handlePurchaseResult(
                result,
                product: product,
                finishAutomatically: finishAutomatically
            )
        } catch {
            throw .wrapped(error: error)
        }
    }
}

extension Mercato {
    private func handlePurchaseResult(
        _ result: Product.PurchaseResult,
        product: Product,
        finishAutomatically: Bool
    ) async throws(MercatoError) -> Purchase {
        switch result {
        case .success(let verification):
            let transaction = try verification.payload

            if finishAutomatically {
                await transaction.finish()
            }

            return Purchase(
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

#if os(macOS) || os(iOS)
@available(macOS 12.0, *)
@available(iOS 15.0, visionOS 1.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension Mercato {
    /// Initiates the refund process for a specified product within a given `UIWindowScene`.
    ///
    /// This function attempts to begin a refund request for a transaction associated with the given product ID.
    /// It handles different refund request outcomes, including user cancellation, success, and unknown errors.
    /// The function is asynchronous and can throw errors if verification or the refund process fails.
    ///
    /// - Parameters:
    ///   - productID: The identifier of the product for which the refund process is being requested.
    ///   - scene: The `UIWindowScene` within which the refund request will be displayed to the user.
    ///
    /// - Throws:
    ///   - `MercatoError.failedVerification`: If the transaction cannot be verified.
    ///   - `MercatoError.canceledByUser`: If the user cancels the refund request.
    ///   - `MercatoError.unknown(error:)`: If an unknown error occurs during the refund process.
    ///   - `MercatoError.refund(error:)`: If a `Transaction.RefundRequestError` occurs during the refund process.
    ///   - `MercatoError.storeKit(error:)`: If a `StoreKitError` occurs during the refund process.
    ///
    /// - Availability:
    ///   - Not available on watchOS or tvOS.
    ///
    /// - Returns:
    ///   No return value. The function will either complete successfully or throw an error.
    @available(macOS 12.0, *)
    @available(iOS 15.0, visionOS 1.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func beginRefundProcess(for productID: String, in displayContext: DisplayContext) async throws(MercatoError) {
        guard let result = await Transaction.latest(for: productID) else {
            throw MercatoError.noTransactionForSpecifiedProduct
        }

        let transaction = try result.payload
        do {
            let status = try await transaction.beginRefundRequest(in: displayContext)

            switch status {
            case .userCancelled:
                throw MercatoError.canceledByUser
            case .success:
                break
            @unknown default:
                throw MercatoError.unknown(error: nil)
            }
        } catch let error as Transaction.RefundRequestError {
            throw MercatoError.refund(error: error)
        } catch {
            throw MercatoError.wrapped(error: error)
        }
    }
}
#endif

