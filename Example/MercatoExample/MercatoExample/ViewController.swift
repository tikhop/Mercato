// MIT License
//
// Copyright (c) 2021-2025 Pavel T
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Mercato
import UIKit

class ViewController: UIViewController {

    private var storeKitUpdatesTask: Task<Void, Never>?

    private func startObservingStoreKitUpdates() {
        storeKitUpdatesTask = Task.detached(priority: .high) {
            // First, let's finish unfinished txs
            for await verificationResult in Mercato.unfinishedTransactions {
                if case .verified(let tx) = verificationResult {
                    // TODO: Send tx.jsonRepresentation to your server and deliver content to your user.
                    await tx.finish()
                }
            }

            // Second, subscribe for updates
            for await verificationResult in Mercato.updates {
                if case .verified(let tx) = verificationResult {
                    // TODO: Send tx.jsonRepresentation to your server and deliver content to your user.
                    await tx.finish()
                }
            }
        }
    }

    private func configureHierarchy() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Buy", for: .normal)
        button.addTarget(self, action: #selector(buyDidTap), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc
    private func buyDidTap() {
        Task {
            let products = try await Mercato.retrieveProducts(productIds: ["product1", "product2"])
            guard let firstProduct = products.first else {
                return
            }

            try await Mercato.purchase(product: firstProduct)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        startObservingStoreKitUpdates()
        configureHierarchy()
    }

    deinit {
        storeKitUpdatesTask?.cancel()
        storeKitUpdatesTask = nil
    }
}

