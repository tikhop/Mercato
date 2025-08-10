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

import Foundation

public final class CurrencySymbolsLibrary: @unchecked Sendable {
    private var symbols: [String: String]
    private let lock: DefaultLock

    init() {
        symbols = [:]
        lock = DefaultLock()
    }

    public func symbol(for code: String) -> String? {
        lock.lock()
        defer { lock.unlock() }

        if let symbol = cachedSymbol(for: code.uppercased()) {
            return symbol
        }

        let symbol = nativeCurrencySymbol(for: code.uppercased())
        symbols[code] = symbol

        return symbol
    }

    private func cachedSymbol(for code: String) -> String? {
        if let symbol = symbols[code] {
            return symbol
        }

        return nil
    }

    private func nativeCurrencySymbol(for currencyCode: String) -> String? {
        var shortestSymbol: String?

        for identifier in Locale.availableIdentifiers {
            let locale = Locale(identifier: identifier)
            let currencyIdentifier: String?
            if #available(iOS 16, *) {
                currencyIdentifier = locale.currency?.identifier
            } else {
                currencyIdentifier = locale.currencyCode
            }
            if currencyIdentifier == currencyCode,
               let symbol = locale.currencySymbol {
                if shortestSymbol == nil || symbol.count < shortestSymbol!.count {
                    shortestSymbol = symbol
                }
            }
        }

        guard let shortestSymbol else {
            return nil
        }

        return shortestSymbol.isEmpty ? nil : shortestSymbol
    }

    public static let shared = CurrencySymbolsLibrary()
}
