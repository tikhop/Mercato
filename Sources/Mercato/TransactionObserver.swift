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

public final class TransactionObserver {
    private var updates: Task<Void, Never>? = nil
    private var handler: TransactionUpdate?

    init(handler: TransactionUpdate?) {
        self.handler = handler
        updates = newTransactionListenerTask()
    }

    public func stop() {
        handler = nil
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

        return transaction
    }

    deinit {
        updates?.cancel()
    }
}
