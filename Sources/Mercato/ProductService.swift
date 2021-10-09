//
//  File.swift
//  
//
//  Created by Pavel Tikhonenko on 09.10.2021.
//

import Foundation
import StoreKit

class ProductService
{
	private var cachedProducts: [Product] = []
	
	@MainActor
	public func retrieveProducts(productIds: Set<String>) async throws -> [Product]
	{
		do
		{
			return try await Product.products(for: productIds)
		}catch{
			throw MercatoError.storeKit(error: error as! StoreKitError)
		}
	}
	
	func isPurchased(_ product: Product) async throws -> Bool
	{
		return try await isPurchased(product.id)
	}
	
	func isPurchased(_ productIdentifier: String) async throws -> Bool
	{
		guard let result = await Transaction.latest(for: productIdentifier) else
		{
			return false
		}
		
		let transaction = try checkVerified(result)
		
		//Ignore revoked transactions, they're no longer purchased.
		
		//For subscriptions, a user can upgrade in the middle of their subscription period. The lower service
		//tier will then have the `isUpgraded` flag set and there will be a new transaction for the higher service
		//tier. Ignore the lower service tier transactions which have been upgraded.
		return transaction.revocationDate == nil && !transaction.isUpgraded
	}
}
