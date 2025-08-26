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

extension Mercato {
    fileprivate static let shared: Mercato = .init()

    /// Returns the current unfinished transactions.
    public static var unfinishedTransactions: Transaction.Transactions {
        Transaction.unfinished
    }

    /// Returns all transactions.
    public static var allTransactions: Transaction.Transactions {
        Transaction.all
    }

    /// Returns the current entitlements.
    public static var currentEntitlements: Transaction.Transactions {
        Transaction.currentEntitlements
    }

    public static var updates: Transaction.Transactions {
        Transaction.updates
    }

    // MARK: - Subscription Status

    /// Checks if a subscription is in billing retry state
    /// - Parameter productId: The product identifier to check
    /// - Returns: True if the subscription is in billing retry, false otherwise
    public static func isInBillingRetry(for productId: String) async -> Bool {
        await shared.isInBillingRetry(for: productId)
    }

    /// Checks if a subscription is in grace period
    /// - Parameter productId: The product identifier to check
    /// - Returns: True if the subscription is in grace period, false otherwise
    public static func isInGracePeriod(for productId: String) async -> Bool {
        await shared.isInGracePeriod(for: productId)
    }

    /// Gets the current renewal state for a subscription
    /// - Parameter productId: The product identifier to check
    /// - Returns: The renewal state or nil if not a subscription
    public static func renewalState(for productId: String) async -> Product.SubscriptionInfo.RenewalState? {
        await shared.renewalState(for: productId)
    }

    // MARK: - Subscription Status Streams

    /// A stream of subscription status updates
    ///
    /// This provides real-time updates when subscription statuses change,
    /// including transitions to billing retry, grace period, expired, etc.
    ///
    /// Example:
    /// ```swift
    /// Task {
    ///     for await status in Mercato.subscriptionStatusUpdates {
    ///         print("Subscription status updated: \(status)")
    ///         // Handle status change
    ///     }
    /// }
    /// ```
    public static var subscriptionStatusUpdates: Product.SubscriptionInfo.Status.Statuses {
        Product.SubscriptionInfo.Status.updates
    }

    /// A stream of all subscription statuses grouped by subscription group ID
    ///
    /// Provides the current status for each subscription group, including
    /// family sharing statuses when applicable.
    ///
    /// Example:
    /// ```swift
    /// Task {
    ///     for await (groupID, statuses) in Mercato.allSubscriptionStatuses {
    ///         print("Group \(groupID) has \(statuses.count) status(es)")
    ///         for status in statuses {
    ///             print("  - State: \(status.state)")
    ///         }
    ///     }
    /// }
    /// ```
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    public static var allSubscriptionStatuses: AsyncStream<(groupID: String, statuses: [Product.SubscriptionInfo.Status])> {
        Product.SubscriptionInfo.Status.all
    }

    public static func latest(for productID: String) async -> VerificationResult<Transaction>? {
        await Transaction.latest(for: productID)
    }

    public static func currentEntitlement(for productID: String) async -> VerificationResult<Transaction>? {
        await Transaction.currentEntitlement(for: productID)
    }

    /// Synchronizes the purchases with the App Store.
    ///
    /// StoreKit automatically keeps signed transaction and renewal info up to date, so this should only be
    /// used if the user indicates they are missing access to a product they have already purchased.
    /// - Important: This will prompt the user to authenticate, only call this function on user interaction.
    /// - Throws: `MercatoError` if the user does not authenticate successfully, or if StoreKit cannot connect to the
    ///           App Store.
    public static func syncPurchases() async throws {
        do {
            try await AppStore.sync()
        } catch let error as StoreKitError {
            throw MercatoError.storeKit(error: error)
        } catch {
            throw MercatoError.unknown(error: error)
        }
    }

    /// A static property available on iOS 16.4 and later that provides access to purchase intents.
    /// This allows developers to retrieve all `PurchaseIntent` objects associated with the app,
    /// enabling tracking or managing purchase-related intents.
    ///
    /// - Note: `PurchaseIntent` objects can help you manage unfinished purchases or gather
    ///         information on user purchase intentions to improve the purchase flow experience.
    @available(iOS 16.4, macOS 14.4, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public static var purchaseIntents: PurchaseIntent.PurchaseIntents {
        PurchaseIntent.intents
    }

    /// Requests product data from the App Store.
    /// - Parameter identifiers: A set of product identifiers to load from the App Store. If any
    ///                          identifiers are not found, they will be excluded from the return
    ///                          value.
    /// - Returns: An array of all the products received from the App Store.
    /// - Throws: `MercatoError`
    public static func retrieveProducts(productIds: Set<String>) async throws(MercatoError) -> [Product] {
        try await Mercato.shared.retrieveProducts(productIds: productIds)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productIds: Set of product ids.
    public static func isEligibleForIntroOffer(for productIds: Set<String>) async throws(MercatoError) -> Bool {
        try await shared.isEligibleForIntroOffer(for: productIds)
    }

    /// Whether the user is eligible to have an introductory offer applied to a purchase in this
    /// subscription group.
    /// - Parameter productId: The product identifier to check eligibility for.
    public static func isEligibleForIntroOffer(for productId: String) async throws(MercatoError) -> Bool {
        try await shared.isEligibleForIntroOffer(for: productId)
    }

    /// Checks if a given product has been purchased.
    ///
    /// - Parameter product: The `Product` to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public static func isPurchased(_ product: Product) async throws(MercatoError) -> Bool {
        try await shared.isPurchased(product)
    }

    /// Checks if a product with the given identifier has been purchased.
    ///
    /// - Parameter productIdentifier: The identifier of the product to check.
    /// - Returns: A Boolean value indicating whether the product has been purchased.
    /// - Throws: `MercatoError` if the purchase status could not be determined.
    public static func isPurchased(_ productIdentifier: String) async throws(MercatoError) -> Bool {
        try await shared.isPurchased(productIdentifier)
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
    public static func purchase(
        productId: String,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws(MercatoError) -> Purchase {
        try await shared.purchase(
            productId: productId,
            promotionalOffer: promotionalOffer,
            quantity: quantity,
            finishAutomatically: finishAutomatically,
            appAccountToken: appAccountToken,
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
    public static func purchase(
        product: Product,
        promotionalOffer: PromotionalOffer? = nil,
        quantity: Int = 1,
        finishAutomatically: Bool = false,
        appAccountToken: UUID? = nil,
        simulatesAskToBuyInSandbox: Bool = false
    ) async throws(MercatoError) -> Purchase {
        try await shared.purchase(
            product: product,
            promotionalOffer: promotionalOffer,
            quantity: quantity,
            finishAutomatically: finishAutomatically,
            appAccountToken: appAccountToken,
            simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox
        )
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
    public static func purchase(
        product: Product,
        options: Set<Product.PurchaseOption>,
        finishAutomatically: Bool
    ) async throws(MercatoError) -> Purchase {
        try await shared.purchase(product: product, options: options, finishAutomatically: finishAutomatically)
    }
}

#if os(macOS) || os(iOS)
@available(macOS 12.0, *)
@available(iOS 15.0, visionOS 1.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension Mercato {
    @available(macOS 12.0, *)
    @available(iOS 15.0, visionOS 1.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public static func beginRefundProcess(for productID: String, in displayContext: DisplayContext) async throws {
        try await shared.beginRefundProcess(for: productID, in: displayContext)
    }
}
#endif

// MARK: Manage Subscription

#if os(iOS)
@available(iOS 15.0, visionOS 1.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension Mercato {
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
    @available(iOS 15.0, visionOS 1.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @MainActor
    public static func showManageSubscriptions(in scene: UIWindowScene) async throws {
        do {
            try await AppStore.showManageSubscriptions(in: scene)
        } catch let error as StoreKitError {
            throw MercatoError.storeKit(error: error)
        } catch {
            throw MercatoError.unknown(error: error)
        }
    }

    @available(iOS 17.0, visionOS 1.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @MainActor
    public static func showManageSubscriptions(in scene: UIWindowScene, subscriptionGroupID: String) async throws {
        do {
            try await AppStore.showManageSubscriptions(in: scene, subscriptionGroupID: subscriptionGroupID)
        } catch let error as StoreKitError {
            throw MercatoError.storeKit(error: error)
        } catch {
            throw MercatoError.unknown(error: error)
        }
    }
}
#endif
