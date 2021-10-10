//
//  File.swift
//  
//
//  Created by Pavel Tikhonenko on 09.10.2021.
//

import Foundation
import StoreKit

public enum MercatoError: Error
{
	case storeKit(error: StoreKitError)
	case purchase(error: Product.PurchaseError)
	case purchaseCanceledByUser
	case userCancelledRefundProcess
	case purchaseIsPending
	case failedVerification
	case genericError
}
