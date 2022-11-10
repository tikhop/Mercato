//
//  File.swift
//  
//
//  Created by tkhp on 10.11.2022.
//

import Foundation
import StoreKit

final class TransactionObserver {
    private var updates: Task<Void, Never>? = nil
    private let handler: TransactionUpdate?
    
    init(handler: TransactionUpdate?) {
        self.handler = handler
        updates = newTransactionListenerTask()
    }
    
    deinit {
        updates?.cancel()
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                if let tx = self.handle(updatedTransaction: verificationResult) {
                    await handler?(tx)
                }
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) -> Transaction? {
        guard case .verified(let transaction) = verificationResult else {
            return nil
        }
        
        if let revocationDate = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about the revoked transaction.
            return nil
        } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            // NOP. This subscription is expired.
            return nil
        } else if transaction.isUpgraded {
            // NOP. There is an active transaction for a higher level of service.
            return nil
        } else {
            return transaction
        }
    }
    
}
