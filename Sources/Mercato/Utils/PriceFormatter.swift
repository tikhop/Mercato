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

@inline(__always)
private let kDefaultFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = .current
    formatter.numberStyle = .currency
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    return formatter
}()

extension Decimal {
    func formattedPrice(
        locale: Locale = .current,
        currencyCode: String,
        applyingRounding: Bool = false
    ) -> String? {
        var formatter = kDefaultFormatter

        if locale != .current {
            formatter = formatter.copy() as! NumberFormatter
            formatter.locale = locale
        }

        formatter.currencyCode = currencyCode

        // Set native currency symbol if available
        if let currencySymbol = CurrencySymbolsLibrary.shared.symbol(for: currencyCode) {
            formatter.currencySymbol = currencySymbol
        }

        if applyingRounding {
            formatter = formatter == kDefaultFormatter ? formatter.copy() as! NumberFormatter : formatter
            formatter.roundingMode = .up
            formatter.maximumFractionDigits = 0
        }

        return formatter.string(from: NSDecimalNumber(decimal: self))
    }
}
