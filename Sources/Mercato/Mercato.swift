import StoreKit

extension Mercato {

    /// Promotional offer for a purchase.
    public struct PromotionalOffer: Sendable {
        /// The `id` property of the `SubscriptionOffer` to apply.
        let offerID: String

        /// The key ID of the private key used to generate `signature`.
        /// The private key and key ID can be generated on App Store Connect.
        let keyID: String

        /// The nonce used in `signature`.
        let nonce: UUID

        /// The cryptographic signature of the offer parameters, generated on your server.
        let signature: Data

        /// The time the signature was generated in milliseconds since 1970.
        let timestamp: Int
    }

    /// A builder class for constructing a set of purchase options for a product.
    public class PurchaseOptionsBuilder {
        /// The quantity of the product to purchase.
        var quantity: Int = 1

        /// An optional promotional offer to apply to the purchase.
        var promotionalOffer: PromotionalOffer? = nil

        /// An optional app account token to associate with the purchase.
        var appAccountToken: UUID? = nil

        /// A flag indicating whether to simulate "Ask to Buy" in the sandbox environment.
        var simulatesAskToBuyInSandbox: Bool = false

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

        public init() {}

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
    private let productService: ProductFetcher

    public convenience init() {
        self.init(productService: BaseProductFetcher())
    }

    public init(productService: ProductFetcher) {
        self.productService = productService
    }

    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `StoreKitError`
    public func retrieveProducts(productIds: Set<String>) async throws -> [Product] {
        try await productService.retrieveProducts(productIds: productIds)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productIds: Set of product ids.
    public func isEligibleForIntroOffer(for productIds: Set<String>) async throws -> Bool {
        let products = try await productService.retrieveProducts(productIds: productIds)

        guard let product = products.first else {
            return false
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
    public func isEligibleForIntroOffer(for productId:  String) async throws -> Bool {
        let products = try await productService.retrieveProducts(productIds: [productId])

        guard let product = products.first else {
            return false
        }

        return await product.isEligibleForIntroOffer
    }

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
    @available(watchOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    func beginRefundProcess(for productID: String, in scene: UIWindowScene) async throws {
        guard case .verified(let transaction) = await Transaction.latest(for: productID) else { throw MercatoError.failedVerification }

        do {
            let status = try await transaction.beginRefundRequest(in: scene)

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
        } catch let error as StoreKitError {
            throw MercatoError.storeKit(error: error)
        } catch {
            throw MercatoError.unknown(error: error)
        }
    }
}

// MARK: - Mercato: Purchase

public extension Mercato {
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
    func purchase(
        productId: String,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws -> Purchase {
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
    func purchase(
        product: Product,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws -> Purchase {
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
    func purchase(
        product: Product,
        options: Set<Product.PurchaseOption>,
        finishAutomatically: Bool
    ) async throws -> Purchase {
        do {
            let result = try await product.purchase(options: options)

            return try await handlePurchaseResult(
                result,
                product: product,
                finishAutomatically: finishAutomatically
            )
        } catch {
            throw handlePurchaseFailure(with: error)
        }
    }
}

private extension Mercato {
    func handlePurchaseResult(
        _ result: Product.PurchaseResult,
        product: Product,
        finishAutomatically: Bool
    ) async throws -> Purchase {
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue

            if finishAutomatically {
                await transaction.finish()
            }

            return Purchase(product: product,
                            result: verification,
                            needsFinishTransaction: !finishAutomatically)
        case .userCancelled:
            throw MercatoError.canceledByUser
        case .pending:
            throw MercatoError.purchaseIsPending
        @unknown default:
            throw MercatoError.unknown(error: nil)
        }
    }

    func handlePurchaseFailure(with error: any Error) -> MercatoError {
        if let e = error as? Product.PurchaseError {
            return MercatoError.purchase(error: e)
        } else if let e = error as? StoreKitError {
            if case .userCancelled = e {
                return MercatoError.canceledByUser
            }

            return MercatoError.storeKit(error: e)
        } else if let e = error as? MercatoError {
            return e
        }

        return MercatoError.unknown(error: error)
    }
}

// MARK: - Mercato: Misc

public extension Mercato {
    fileprivate static let shared: Mercato = .init()

    /// Returns the current unfinished transactions.
    static var unfinishedTransactions: Transaction.Transactions {
        return Transaction.unfinished
    }

    /// Returns all transactions.
    static var allTransactions: Transaction.Transactions {
        return Transaction.all
    }

    /// Returns the current entitlements.
    static var currentEntitlements: Transaction.Transactions {
        return Transaction.currentEntitlements
    }

    static var updates: Transaction.Transactions {
        return Transaction.updates
    }

    static func latest(for productID: String) async -> VerificationResult<Transaction>? {
        return await Transaction.latest(for: productID)
    }

    static func currentEntitlement(for productID: String) async -> VerificationResult<Transaction>? {
        return await Transaction.currentEntitlement(for: productID)
    }

    /// Synchronizes the purchases with the App Store.
    ///
    /// StoreKit automatically keeps signed transaction and renewal info up to date, so this should only be
    /// used if the user indicates they are missing access to a product they have already purchased.
    /// - Important: This will prompt the user to authenticate, only call this function on user interaction.
    /// - Throws: If the user does not authenticate successfully, or if StoreKit cannot connect to the
    ///           App Store.
    static func syncPurchases() async throws {
        try await AppStore.sync()
    }

    /// Displays the subscription management interface for the user within the specified `UIWindowScene`.
    ///
    /// This function presents the App Store's manage subscriptions screen, allowing the user to view and manage their active subscriptions.
    /// It is asynchronous and throws errors if there are issues invoking the subscription management screen.
    ///
    /// - Parameters:
    ///   - scene: The `UIWindowScene` within which the subscription management interface will be presented.
    ///
    /// - Throws:
    ///   - An error if the subscription management interface could not be presented.
    ///
    /// - Availability:
    ///   - Available on iOS 15.0 and later.
    ///   - Not available on macOS, watchOS, or tvOS.
    ///
    /// - Returns:
    ///   No return value. The function will either complete successfully or throw an error.
    @available(iOS 15.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    static func showManageSubscriptions(in scene: UIWindowScene) async throws {
        try await AppStore.showManageSubscriptions(in: scene)
    }

    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `StoreKitError`
    static func retrieveProducts(productIds: Set<String>) async throws -> [Product] {
        try await Mercato.shared.retrieveProducts(productIds: productIds)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productIds: Set of product ids.
    static func isEligibleForIntroOffer(for productIds: Set<String>) async throws -> Bool {
        try await shared.isEligibleForIntroOffer(for: productIds)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productId: The product identifier to check eligibility for.
    static func isEligibleForIntroOffer(for productId: String) async throws -> Bool {
        try await shared.isEligibleForIntroOffer(for: productId)
    }

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
    @available(watchOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    static func beginRefundProcess(for productID: String, in scene: UIWindowScene) async throws {
        try await shared.beginRefundProcess(for: productID, in: scene)
    }

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
    static func purchase(
        productId: String,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws -> Purchase {
        try await shared.purchase(productId: productId,
                                  promotionalOffer: promotionalOffer,
                                  quantity: quantity,
                                  finishAutomatically: finishAutomatically,
                                  appAccountToken: appAccountToken,
                                  simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
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
    static func purchase(
        product: Product,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws -> Purchase {
        try await shared.purchase(product: product,
                                  promotionalOffer: promotionalOffer,
                                  quantity: quantity,
                                  finishAutomatically: finishAutomatically,
                                  appAccountToken: appAccountToken,
                                  simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox)
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
    static func purchase(
        product: Product,
        options: Set<Product.PurchaseOption>,
        finishAutomatically: Bool
    ) async throws -> Purchase {
        try await shared.purchase(product: product, options: options, finishAutomatically: finishAutomatically)
    }
}
