//
//  File.swift
//  
//
//  Created by PT on 8/13/23.
//

import StoreKit

public final class CurrentEntitlementObserver: TransactionObserver {
    private var updates: Task<Void, Never>? = nil
    private var handler: TransactionUpdate?

    init(onlyRenewable: Bool, handler: @escaping TransactionUpdate) {
        super.init(transactionSequence: Transaction.currentEntitlements) { tx in
            if tx.productType == .autoRenewable ||
                (!onlyRenewable && tx.productType == .nonRenewable) {
                await handler(tx)
            }
        }
    }

    private func newTransactionListenerTask(sequence: Transaction.Transactions) -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in sequence {
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

        return transaction
    }

    deinit {
        updates?.cancel()
    }
}
