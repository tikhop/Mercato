//
//  File.swift
//
//
//  Created by tkhp on 10.11.2022.
//

import Foundation
import StoreKit

public typealias TransactionObserverHandler = UUID
public typealias TransactionUpdate = (Transaction) async -> ()

// MARK: - TransactionObserver

class TransactionObserver {
    private var updates: Task<Void, Never>? = nil
    private var handler: TransactionUpdate?

    init(transactionSequence: Transaction.Transactions, handler: TransactionUpdate?) {
        self.handler = handler
        self.updates = newTransactionListenerTask(sequence: transactionSequence)
    }

    public func stop() {
        handler = nil
        updates?.cancel()
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
