//
//  ExtensionTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 24.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Testing
@testable import SharedModels
import SwiftUI
import EventKit

extension Tag {
    @Tag static var need: Self
}


@Suite("Date Extension Tests") struct DateExtensionTests {
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
    
    @Test func printTime() throws {
        let eightPM = Date.eightPM
        let expectedPrint = "20:00"
        let printedTime = eightPM.printTime(locale: .init(identifier: "tr"))
        #expect(expectedPrint == printedTime)
    }
    
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
    
    @Test func randomDate() throws {
        let randomDate = Calendar.current.date(from: .generateRandomDateComponent()) ?? .now
        #expect(randomDate != .now)
    }
    
    @Test func lateDate() throws {
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: .now) ?? .now
        #expect(Calendar.current.isDateLater(date: threeDaysLater))
    }
}

@Suite("String Extension Tests") struct StringExtensionTests {

    @Test func footerLabel() throws {
        let content = Strings.footerLabel("2023")
        #expect(content == "© Ege Sucu 2023")
    }

    @MainActor
    @Test("", .tags(.need)) func formattingCurrentEventDateTime() throws {
        let current = true
        let allDay = true
        let manager = EventManager(isDemo: true)
        let event = manager.events.first ?? .init(eventStore: manager.eventStore)
        let expectedContent = String.formatEventDateTime(
            current: current,
            allDay: allDay,
            event: event
        )
        let allDayTitle = String(localized: "all_day_title")
        #expect(expectedContent == allDayTitle)

        let expectedFutureAllDayTitle = String.formatEventDateTime(
            current: false,
            allDay: allDay,
            event: event
        )

        let futureAllDayTitle = String.futureDateTimeFormat(
            allDay: allDay,
            event: event
        )
        #expect(expectedFutureAllDayTitle == futureAllDayTitle)

        let expectedCurrentTitle = String
            .formatEventDateTime(
                current: current,
                allDay: false,
                event: event
            )

        let currentEventTitle = String
            .currentDateTimeFormat(
                allDay: false,
                event: event
            )
        #expect(expectedCurrentTitle == currentEventTitle)

        let expectedFutureTitle = String
            .formatEventDateTime(
                current: false,
                allDay: false,
                event: event
            )

        let futureEventTitle = String
            .futureDateTimeFormat(
                allDay: false,
                event: event
            )
        #expect(expectedFutureTitle == futureEventTitle)

    }

}

@Suite("Array Extension Testing")
struct ArrayTests {
    @Test func testIsNotEmpty() throws {
        let intArray = [1, 2, 3]
        #expect(intArray.isNotEmpty == !intArray.isEmpty)
        
        let word = "Test"
        #expect(word.isNotEmpty == !word.isEmpty)
    }
    
    @Test func testArrayDuplicateRemoval() throws {
        let array = [1, 2, 4, 6, 2, 4]
        let uniqueArray = array
            .removeDuplicates()
            .sorted()
        #expect(uniqueArray == [1, 2, 4, 6])
    }
    
    @Test func removeDuplicates() throws {
        let array = [1, 2, 4, 6, 2, 4]
        let uniqueArray = array.removeDuplicates()
        #expect(uniqueArray == [1, 2, 4, 6])
    }
    
    @Test func emptyArray() throws {
        let emptyArray = [Int]()
        #expect(emptyArray == .empty)
    }
    
    @Test func testSafeIndexAccess() throws {
        let demo = [3, 4, 5, 6, 7, 8, 9, 10]
        let thirdIndex = demo[safe: 3]
        #expect(thirdIndex != nil)
        #expect(thirdIndex == 6)
        #expect(demo[safe: 20] == nil)
    }
    
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
