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
}
