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
import Testing
@testable import Mercato

@Suite("CurrencySymbolsLibrary Tests")
struct CurrencySymbolsLibraryTests {

    @Suite("Common Currency Symbols")
    struct CommonCurrencyTests {

        @Test("Returns correct symbol for USD")
        func testUSDSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "USD")
            #expect(symbol == "$")
        }

        @Test("Returns correct symbol for EUR")
        func testEURSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "EUR")
            #expect(symbol == "€")
        }

        @Test("Returns correct symbol for GBP")
        func testGBPSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "GBP")
            #expect(symbol == "£")
        }

        @Test("Returns correct symbol for JPY")
        func testJPYSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "JPY")
            #expect(symbol == "¥")
        }

        @Test("Returns correct symbol for CNY")
        func testCNYSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "CNY")
            #expect(symbol == "￥" || symbol == "¥" || symbol == "元")
        }

        @Test("Returns correct symbol for CAD")
        func testCADSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "CAD")
            #expect(symbol == "$" || symbol == "CA$")
        }

        @Test("Returns correct symbol for AUD")
        func testAUDSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "AUD")
            #expect(symbol == "$" || symbol == "A$")
        }

        @Test("Returns correct symbol for CHF")
        func testCHFSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "CHF")
            #expect(symbol == "CHF" || symbol == "Fr")
        }

        @Test("Returns correct symbol for INR")
        func testINRSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "INR")
            #expect(symbol == "₹")
        }

        @Test("Returns correct symbol for KRW")
        func testKRWSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "KRW")
            #expect(symbol == "₩")
        }

        @Test("Returns correct symbol for RUB")
        func testRUBSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "RUB")
            #expect(symbol == "₽")
        }

        @Test("Returns correct symbol for BRL")
        func testBRLSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "BRL")
            #expect(symbol == "R$")
        }

        @Test("Returns correct symbol for MXN")
        func testMXNSymbol() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "MXN")
            #expect(symbol == "$" || symbol == "MX$")
        }
    }

    @Suite("Edge Cases")
    struct EdgeCaseTests {

        @Test("Returns nil for unknown currency")
        func testUnknownCurrency() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "XaYZ")
            #expect(symbol == nil)
        }

        @Test("Handles lowercase currency codes")
        func testLowercaseCurrencyCode() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "usd")
            // Should either handle case-insensitively or return nil
            #expect(symbol == "$")
        }

        @Test("Handles empty string")
        func testEmptyString() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "")
            #expect(symbol == nil)
        }

        @Test("Handles special characters in currency code")
        func testSpecialCharacters() {
            let symbol = CurrencySymbolsLibrary.shared.symbol(for: "US$")
            #expect(symbol == nil)
        }
    }

    @Test("Thread safety of shared instance")
    func testThreadSafety() async {
        // Test concurrent access to the shared instance
        await withTaskGroup(of: String?.self) { group in
            for currency in ["USD", "EUR", "GBP", "JPY"] {
                group.addTask {
                    CurrencySymbolsLibrary.shared.symbol(for: currency)
                }
            }

            var results: [String?] = []
            for await result in group {
                results.append(result)
            }

            // All results should be valid
            #expect(results.count == 4)
            #expect(results.contains { $0 == "$" })
            #expect(results.contains { $0 == "€" })
            #expect(results.contains { $0 == "£" })
            #expect(results.contains { $0 == "¥" })
        }
    }
}
