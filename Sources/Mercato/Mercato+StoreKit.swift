//
//  File.swift
//
//
//  Created by Pavel Tikhonenko on 10.10.2021.
//

import Foundation
import StoreKit

typealias RenewalState = Product.SubscriptionInfo.RenewalState

extension Product {
    public var isEligibleForIntroOffer: Bool {
        get async {
            await subscription?.isEligibleForIntroOffer ?? false
        }
    }

    public var hasActiveSubscription: Bool {
        get async {
            await (try? subscription?.status.first?.state == RenewalState.subscribed) ?? false
        }
    }
}
