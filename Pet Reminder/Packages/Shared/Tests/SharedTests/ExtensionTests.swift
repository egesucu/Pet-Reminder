//
//  ExtensionTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 24.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

/// This test file contains unit tests for extensions on Date, String, and Array types provided in the Shared module.
/// It verifies the correctness of date conversions, string formatting utilities, and array manipulation methods.

import Foundation
import Testing
import Shared

/// Extension to define custom tags to categorize and filter tests.
/// Use `@Tag.need` to mark tests that require specific conditions or resources.
extension Tag {
    @Tag static var need: Self
}

/// Test suite for Date extension methods.
/// Covers date parsing, formatting, random date generation, and date comparison utilities.
@Suite("Date Extension Tests") struct DateExtensionTests {
    
    /// Tests converting a Turkish locale date string to a Date object.
    /// Expects that the conversion matches the expected Date at start of day.
    @Test func dateConversion() throws {
        let testDate = Calendar.current.startOfDay(
            for: "24 Eki 2023".convertStringToDate(
                locale: .init(identifier: "tr")
            )
        )
        let nowString = "24 Eki 2023"
        let expectedDate = Calendar.current.startOfDay(
            for: nowString.convertStringToDate(locale: .init(identifier: "tr"))
        )
        #expect(expectedDate == testDate)
    }

    /// Tests printing the time component of a Date object.
    /// Expects the time "20:00" for the static `eightPM` date.
    @Test func printTime() throws {
        let eightPM = Date.eightPM
        let expectedPrint = "20:00"
        let printedTime = eightPM.printTime(locale: .init(identifier: "tr"))
        #expect(expectedPrint == printedTime)
    }

    /// Tests printing the date component in a Turkish locale and replacing slashes with dots.
    /// Expects the formatted date string to match "24.10.2023".
    @Test func printDate() throws {
        let dateString = "24.10.2023"
        let expectedDate = Calendar
            .current
            .startOfDay(
                for: "24 Eki 2023".convertStringToDate(locale: .init(identifier: "tr"))
            )
            .printDate(locale: .init(identifier: "tr")).replacingOccurrences(of: "/", with: ".")

        #expect(expectedDate == dateString)
    }

    /// Tests generating a random Date from random date components.
    /// Expects the random date to not be equal to the current date.
    @Test func randomDate() throws {
        let randomDate = Calendar.current.date(from: .generateRandomDateComponent()) ?? .now
        #expect(randomDate != .now)
    }

    /// Tests if a date three days later than now is recognized as later by the utility.
    /// Expects the later date to be identified correctly.
    @Test func lateDate() throws {
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: .now) ?? .now
        #expect(Calendar.current.isDateLater(date: threeDaysLater))
    }
}

/// Test suite for String extension methods.
/// Includes tests for generating localized footer labels and string utilities.
@Suite("String Extension Tests") struct StringExtensionTests {

    /// Tests the `footerLabel` method that generates copyright footer text.
    /// Expects the output to match "© Ege Sucu 2023".
    @MainActor
    @Test func footerLabel() throws {
        let content = Strings.footerLabel("2023")
        #expect(content == "© Ege Sucu 2023")
    }

}

/// Test suite for Array extension methods.
/// Tests various utilities like duplicate removal, safe indexing, and keyPath filtering.
@Suite("Array Extension Testing")
struct ArrayTests {
    
    /// Tests the `isNotEmpty` computed property on both array and string.
    /// Expects `isNotEmpty` to be the inverse of `isEmpty`.
    @Test func testIsNotEmpty() throws {
        let intArray = [1, 2, 3]
        #expect(intArray.isNotEmpty == !intArray.isEmpty)

        let word = "Test"
        #expect(word.isNotEmpty == !word.isEmpty)
    }

    /// Tests removing duplicates from an integer array and sorting the result.
    /// Expects the resulting array to contain unique sorted elements.
    @Test func testArrayDuplicateRemoval() throws {
        let array = [1, 2, 4, 6, 2, 4]
        let uniqueArray = array
            .removeDuplicates()
            .sorted()
        #expect(uniqueArray == [1, 2, 4, 6])
    }

    /// Tests removing duplicates from an integer array.
    /// Expects a unique array maintaining original order of first occurrences.
    @Test func removeDuplicates() throws {
        let array = [1, 2, 4, 6, 2, 4]
        let uniqueArray = array.removeDuplicates()
        #expect(uniqueArray == [1, 2, 4, 6])
    }

    /// Tests behavior on an empty integer array.
    /// Expects the empty array to be equal to `.empty`.
    @Test func emptyArray() throws {
        let emptyArray = [Int]()
        #expect(emptyArray == .empty)
    }

    /// Tests safe indexing into an array.
    /// Expects valid indices to return correct elements and out-of-bounds indices to return nil.
    @Test func testSafeIndexAccess() throws {
        let demo = [3, 4, 5, 6, 7, 8, 9, 10]
        let thirdIndex = demo[safe: 3]
        #expect(thirdIndex != nil)
        #expect(thirdIndex == 6)
        #expect(demo[safe: 20] == nil)
    }

    /// Tests filtering an array of structs using a keyPath boolean property.
    /// Expects only active items to be returned and verifies their names.
    @Test func testFilterWithKeyPath() throws {

        struct TestModel {
            let isActive: Bool
            let name: String
        }

        // Create test data
        let items = [
            TestModel(isActive: true, name: "Item 1"),
            TestModel(isActive: false, name: "Item 2"),
            TestModel(isActive: true, name: "Item 3"),
            TestModel(isActive: false, name: "Item 4")
        ]

        // Use the keyPath filter method
        let filteredItems = items.filter(\.isActive)

        // Verify the result
        #expect(filteredItems.count == 2)
        #expect(filteredItems[0].name == "Item 1")
        #expect(filteredItems[1].name == "Item 3")
    }
}

