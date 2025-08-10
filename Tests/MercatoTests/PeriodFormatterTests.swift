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

@Suite("PeriodFormatter Tests")
enum PeriodFormatterTests {

    @Suite("Format Period")
    struct FormatPeriodTests {

        @Test("Formats single day")
        func testSingleDay() {
            let formatted = PeriodFormatter.format(unit: .day, numberOfUnits: 1)
            #expect(formatted == "1 day")
        }

        @Test("Formats multiple days")
        func testMultipleDays() {
            let formatted = PeriodFormatter.format(unit: .day, numberOfUnits: 3)
            #expect(formatted == "3 days")
        }

        @Test("Formats single week")
        func testSingleWeek() {
            let formatted = PeriodFormatter.format(unit: .weekOfMonth, numberOfUnits: 1)
            #expect(formatted == "1 week")
        }

        @Test("Formats multiple weeks")
        func testMultipleWeeks() {
            let formatted = PeriodFormatter.format(unit: .weekOfMonth, numberOfUnits: 2)
            #expect(formatted == "2 weeks")
        }

        @Test("Formats single month")
        func testSingleMonth() {
            let formatted = PeriodFormatter.format(unit: .month, numberOfUnits: 1)
            #expect(formatted == "1 month")
        }

        @Test("Formats multiple months")
        func testMultipleMonths() {
            let formatted = PeriodFormatter.format(unit: .month, numberOfUnits: 6)
            #expect(formatted == "6 months")
        }

        @Test("Formats single year")
        func testSingleYear() {
            let formatted = PeriodFormatter.format(unit: .year, numberOfUnits: 1)
            #expect(formatted == "1 year")
        }

        @Test("Formats multiple years")
        func testMultipleYears() {
            let formatted = PeriodFormatter.format(unit: .year, numberOfUnits: 2)
            #expect(formatted == "2 years")
        }
    }

    @Suite("Special Cases")
    struct SpecialCasesTests {

        @Test("Handles zero units")
        func testZeroUnits() {
            let formatted = PeriodFormatter.format(unit: .day, numberOfUnits: 0)
            // Depending on implementation, this might return nil or "0 days"
            #expect(formatted == nil || formatted == "0 days")
        }

        @Test("Handles common subscription periods")
        func testCommonSubscriptionPeriods() {
            // Weekly
            let weekly = PeriodFormatter.format(unit: .weekOfMonth, numberOfUnits: 1)
            #expect(weekly == "1 week")

            // Monthly
            let monthly = PeriodFormatter.format(unit: .month, numberOfUnits: 1)
            #expect(monthly == "1 month")

            // Quarterly
            let quarterly = PeriodFormatter.format(unit: .month, numberOfUnits: 3)
            #expect(quarterly == "3 months")

            // Semi-annual
            let semiAnnual = PeriodFormatter.format(unit: .month, numberOfUnits: 6)
            #expect(semiAnnual == "6 months")

            // Annual
            let annual = PeriodFormatter.format(unit: .year, numberOfUnits: 1)
            #expect(annual == "1 year")
        }

        @Test("Handles trial periods")
        func testTrialPeriods() {
            // 3-day trial
            let threeDayTrial = PeriodFormatter.format(unit: .day, numberOfUnits: 3)
            #expect(threeDayTrial == "3 days")

            // 7-day trial
            let sevenDayTrial = PeriodFormatter.format(unit: .day, numberOfUnits: 7)
            #expect(sevenDayTrial == "7 days")

            // 14-day trial
            let fourteenDayTrial = PeriodFormatter.format(unit: .day, numberOfUnits: 14)
            #expect(fourteenDayTrial == "14 days")

            // 30-day trial
            let thirtyDayTrial = PeriodFormatter.format(unit: .day, numberOfUnits: 30)
            #expect(thirtyDayTrial == "30 days")
        }
    }

    @Suite("Localization")
    struct LocalizationTests {

        @Test("Returns English format by default")
        func testEnglishFormatDefault() {
            // The formatter should return English by default
            let formatted = PeriodFormatter.format(unit: .month, numberOfUnits: 1)
            #expect(formatted == "1 month")
        }

        @Test("Handles plural forms correctly")
        func testPluralForms() {
            // Singular forms
            #expect(PeriodFormatter.format(unit: .day, numberOfUnits: 1) == "1 day")
            #expect(PeriodFormatter.format(unit: .weekOfMonth, numberOfUnits: 1) == "1 week")
            #expect(PeriodFormatter.format(unit: .month, numberOfUnits: 1) == "1 month")
            #expect(PeriodFormatter.format(unit: .year, numberOfUnits: 1) == "1 year")

            // Plural forms
            #expect(PeriodFormatter.format(unit: .day, numberOfUnits: 2)?.contains("days") == true)
            #expect(PeriodFormatter.format(unit: .weekOfMonth, numberOfUnits: 2)?.contains("weeks") == true)
            #expect(PeriodFormatter.format(unit: .month, numberOfUnits: 2)?.contains("months") == true)
            #expect(PeriodFormatter.format(unit: .year, numberOfUnits: 2)?.contains("years") == true)
        }
    }
}
