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
	public var productId: String
	{
		transaction.productID
	}
	
    public var quantity: Int
	{
		transaction.purchasedQuantity
	}
	
    public func finish() async
	{
		await transaction.finish()
	}
}
