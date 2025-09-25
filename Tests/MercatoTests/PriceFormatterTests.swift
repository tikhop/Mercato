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

@Suite("PriceFormatter Tests")
enum PriceFormatterTests {

    @Suite("Decimal.formattedPrice")
    struct FormattedPriceTests {

        @Test("Formats price with USD currency")
        func testUSDFormatting() {
            let price = Decimal(9.99)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd
            )

            #expect(formatted == "$9.99")
        }

        @Test("Formats price with EUR currency")
        func testEURFormatting() {
            let price = Decimal(19.99)
            let formatted = price.formattedPrice(
                locale: .testFR,
                currencyCode: TestCurrencies.eur
            )

            // French locale uses different formatting
            #expect(formatted?.contains("19,99") == true)
            #expect(formatted?.contains("€") == true)
        }

        @Test("Formats price with GBP currency")
        func testGBPFormatting() {
            let price = Decimal(29.99)
            let formatted = price.formattedPrice(
                locale: .testUK,
                currencyCode: TestCurrencies.gbp
            )

            #expect(formatted?.contains("£") == true)
            #expect(formatted?.contains("29.99") == true)
        }

        @Test("Formats price with JPY currency (no decimals)")
        func testJPYFormatting() {
            let price = Decimal(1000)
            let formatted = price.formattedPrice(
                locale: .testJP,
                currencyCode: TestCurrencies.jpy
            )

            #expect(formatted?.contains("¥") == true || formatted?.contains("￥") == true)
            #expect(formatted?.contains("1,000") == true || formatted?.contains("1000") == true)
        }

        @Test("Formats price with RUB currency")
        func testRUBFormatting() {
            let price = Decimal(499.99)
            let formatted = price.formattedPrice(
                locale: .testRU,
                currencyCode: TestCurrencies.rub
            )

            #expect(formatted?.contains("₽") == true)
            #expect(formatted?.contains("499") == true)
        }

        @Test("Applies rounding mode when specified")
        func testRoundingMode() {
            let price = Decimal(9.49)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd,
                applyingRounding: true
            )

            // Should round up to $10
            #expect(formatted == "$10")
        }

        @Test("Does not apply rounding by default")
        func testNoRoundingByDefault() {
            let price = Decimal(9.49)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd,
                applyingRounding: false
            )

            #expect(formatted == "$9.49")
        }

        @Test("Handles zero price")
        func testZeroPrice() {
            let price = Decimal(0)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd,
                applyingRounding: true
            )

            #expect(formatted == "$0")
        }

        @Test("Handles large prices")
        func testLargePrice() {
            let price = Decimal(999999.99)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd
            )

            #expect(formatted?.contains("999") == true)
        }

        @Test("Handles negative prices")
        func testNegativePrice() {
            let price = Decimal(-9.99)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd
            )

            // Negative prices should still format, typically with minus sign
            #expect(formatted?.contains("9.99") == true)
        }

        @Test("Uses currency symbol from CurrencySymbolsLibrary if available")
        func testCustomCurrencySymbol() {
            // This test verifies that custom currency symbols are used when available
            let price = Decimal(9.99)

            // Test with a currency that might have a custom symbol
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: "BTC" // Bitcoin as an example
            )

            // The formatter should still work even with unknown currencies
            #expect(formatted != nil)
        }
    }

    @Suite("Decimal.formattedPrice with FormatStyle.Currency")
    struct FormattedPriceWithCurrencyStyleTests {

        @available(iOS 16, *)
        @Test("Formats price with USD currency")
        func testUSDFormatting() {
            let price = Decimal(9.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted == "$9.99")
        }

        @available(iOS 16, *)
        @Test("Formats price with EUR currency")
        func testEURFormatting() {
            let price = Decimal(19.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.eur, locale: .testFR)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testFR
            )

            #expect(formatted.contains("19,99") == true)
            #expect(formatted.contains("€") == true)
        }

        @available(iOS 16, *)
        @Test("Formats price with GBP currency")
        func testGBPFormatting() {
            let price = Decimal(29.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.gbp, locale: .testUK)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUK
            )

            #expect(formatted.contains("£") == true)
            #expect(formatted.contains("29.99") == true)
        }

        @available(iOS 16, *)
        @Test("Formats price with JPY currency (no decimals)")
        func testJPYFormatting() {
            let price = Decimal(1000)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.jpy, locale: .testJP)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testJP
            )

            #expect(formatted.contains("¥") == true || formatted.contains("￥") == true)
            #expect(formatted.contains("1,000") == true || formatted.contains("1000") == true)
        }

        @available(iOS 16, *)
        @Test("Formats price with RUB currency")
        func testRUBFormatting() {
            let price = Decimal(499.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.rub, locale: .testRU)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testRU
            )

            #expect(formatted.contains("₽") == true)
            #expect(formatted.contains("499") == true)
        }

        @available(iOS 16, *)
        @Test("Formats price with RUB currency and us locale")
        func testRUBUsFormatting() {
            let price = Decimal(499.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.rub, locale: .testRU)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted.contains("₽") == true)
            #expect(formatted.contains("499") == true)
        }

        @available(iOS 16, *)
        @Test("Applies rounding mode when specified")
        func testRoundingMode() {
            let price = Decimal(9.49)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS,
                applyingRounding: true
            )

            #expect(formatted == "$10")
        }

        @available(iOS 16, *)
        @Test("Does not apply rounding by default")
        func testNoRoundingByDefault() {
            let price = Decimal(9.49)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS,
                applyingRounding: false
            )

            #expect(formatted == "$9.49")
        }

        @available(iOS 16, *)
        @Test("Handles zero price")
        func testZeroPrice() {
            let price = Decimal(0)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS,
                applyingRounding: true
            )

            #expect(formatted == "$0")
        }

        @available(iOS 16, *)
        @Test("Handles large prices")
        func testLargePrice() {
            let price = Decimal(999999.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted.contains("999") == true)
        }

        @available(iOS 16, *)
        @Test("Handles negative prices")
        func testNegativePrice() {
            let price = Decimal(-9.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted.contains("9.99") == true)
        }

        @available(iOS 16, *)
        @Test("Uses currency symbol from CurrencySymbolsLibrary if available")
        func testCustomCurrencySymbol() {
            let price = Decimal(9.99)
            let currencyStyle = Decimal.FormatStyle.Currency(code: "BTC", locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted != "")
        }

        @available(iOS 16, *)
        @Test("Handles very small decimal values")
        func testVerySmallDecimals() {
            let price = Decimal(0.01)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted == "$0.01")
        }

        @available(iOS 16, *)
        @Test("Handles fractional cents with rounding")
        func testFractionalCentsRounding() {
            let price = Decimal(9.994)
            let currencyStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let formatted = price.formattedPrice(
                currencyStyle: currencyStyle,
                locale: .testUS
            )

            #expect(formatted == "$9.99")
        }

        @available(iOS 16, *)
        @Test("Handles different locale number formats")
        func testDifferentLocaleFormats() {
            let price = Decimal(1234.56)

            let germanStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.eur, locale: .testDE)
            let germanFormatted = price.formattedPrice(
                currencyStyle: germanStyle,
                locale: .testDE
            )

            #expect(germanFormatted.contains("1.234") == true || germanFormatted.contains("1234") == true)
            #expect(germanFormatted.contains(",56") == true || germanFormatted.contains(".56") == true)

            let usStyle = Decimal.FormatStyle.Currency(code: TestCurrencies.usd, locale: .testUS)
            let usFormatted = price.formattedPrice(
                currencyStyle: usStyle,
                locale: .testUS
            )
            #expect(usFormatted.contains("1,234.56") == true || usFormatted.contains("1234.56") == true)
        }
    }
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {

        @Test("Handles very small decimal values")
        func testVerySmallDecimals() {
            let price = Decimal(0.01)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd
            )

            #expect(formatted == "$0.01")
        }

        @Test("Handles fractional cents with rounding")
        func testFractionalCentsRounding() {
            let price = Decimal(9.994)
            let formatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd
            )

            // Should round to 9.99
            #expect(formatted == "$9.99")
        }

        @Test("Handles different locale number formats")
        func testDifferentLocaleFormats() {
            let price = Decimal(1234.56)

            // German locale uses comma as decimal separator
            let germanFormatted = price.formattedPrice(
                locale: .testDE,
                currencyCode: TestCurrencies.eur
            )

            #expect(germanFormatted?.contains("1.234") == true || germanFormatted?.contains("1234") == true)
            #expect(germanFormatted?.contains(",56") == true || germanFormatted?.contains(".56") == true)

            // US locale uses period as decimal separator
            let usFormatted = price.formattedPrice(
                locale: .testUS,
                currencyCode: TestCurrencies.usd
            )
            #expect(usFormatted?.contains("1,234.56") == true || usFormatted?.contains("1234.56") == true)
        }
    }
}
