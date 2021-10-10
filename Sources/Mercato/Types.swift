//
//  File.swift
//  
//
//  Created by Pavel Tikhonenko on 09.10.2021.
//


import StoreKit


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
	
	func finish() async
	{
		await transaction.finish()
	}
	
//	init(product: Product, transaction: Transaction, needsFinishTransaction: Bool)
//	{
//		self.product = product
//		self.needsFinishTransaction = needsFinishTransaction
//		self.transaction = transaction
//	}
}
