//
//  File.swift
//  
//
//  Created by Pavel Tikhonenko on 09.10.2021.
//

import Foundation
import StoreKit

/// Purchase result
public enum PurchaseResult
{
	case success(purchase: Purchase)
	case error(error: MercatoError)
}

public struct Purchase
{
	public let product: Product
	public let transaction: Transaction
	//public let originalTransaction: Transaction?
	public let needsFinishTransaction: Bool
}

extension Purchase
{
	var productId: String
	{
		transaction.productID
	}
	
	var quantity: Int
	{
		transaction.purchasedQuantity
	}
	
//	init(product: Product, transaction: Transaction, needsFinishTransaction: Bool)
//	{
//		self.product = product
//		self.needsFinishTransaction = needsFinishTransaction
//		self.transaction = transaction
//	}
}
