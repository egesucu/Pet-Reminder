//
//  ExtensionTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 24.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import XCTest
@testable import Pet_Reminder
import SwiftUI
import EventKit

final class ExtensionTests: XCTestCase {
    
    func testLoadImage() throws {
        let imageName = "both"
        let uiImage: UIImage = UIImage.loadImage(name: imageName)
        let realImage = UIImage(named: imageName)
        XCTAssertEqual(realImage, uiImage)
    }
    
    func testIfDarkColor() throws {
        let blue = Color.blue
        let lightGray = Color(.lightGray)
        
        XCTAssertTrue(blue.isDarkColor)
        XCTAssertFalse(lightGray.isDarkColor)
    }
    
    func testStringConversion() throws {
        let now = Date.now
        let nowString = Date.now.formatted(.dateTime.day().month(.twoDigits).year())
        let expectedDate = now.convertDateToString()
            .replacingOccurrences(of: " ", with: ".")
        XCTAssertEqual(expectedDate, nowString)
    }
    
    func testDateConversion() throws {
        let testDate = Date().convertStringToDate(string: "24 Eki 2023")
        let nowString = "24 Eki 2023"
        let expectedDate = Calendar.current.startOfDay(
            for: Date().convertStringToDate(
                string: nowString
            )
        )
        XCTAssertEqual(expectedDate, testDate)
    }
    
    func testPrintTime() throws {
        let eightPM = Date.eightPM
        let expectedPrint = "20:00"
        let printedTime = eightPM.printTime()
        XCTAssertEqual(expectedPrint, printedTime)
    }
    
    func testPrintDate() throws {
        let dateString = "24.10.2023"
        let expectedDate = Date()
            .convertStringToDate(string: "24 Eki 2023")
            .printDate()
        XCTAssertEqual(expectedDate, dateString)
    }
    
    func testRandomDate() throws {
        let randomDate = Calendar.current.date(from: .generateRandomDateComponent()) ?? .now
        XCTAssertTrue(randomDate != .now)
    }
    
    func testLateDate() throws {
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: .now) ?? .now
        XCTAssertTrue(Calendar.current.isDateLater(date: threeDaysLater))
    }
    
    func testFooterLabel() throws {
        let content = Strings.footerLabel("2023")
        XCTAssertTrue(content == "© Ege Sucu 2023")
    }
    
    func testFormattingCurrentEventDateTime() throws {
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
        XCTAssertEqual(expectedContent, allDayTitle)
        
        let expectedFutureAllDayTitle = String.formatEventDateTime(
            current: false,
            allDay: allDay,
            event: event
        )
        
        let futureAllDayTitle = String.futureDateTimeFormat(
            allDay: allDay,
            event: event
        )
        XCTAssertEqual(expectedFutureAllDayTitle, futureAllDayTitle)
        
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
        XCTAssertEqual(expectedCurrentTitle, currentEventTitle)
        
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
        XCTAssertEqual(expectedFutureTitle, futureEventTitle)
            
    }
    
    func testIsNotEmpty() throws {
        let intArray = [1,2,3]
        XCTAssertEqual(intArray.isNotEmpty, !intArray.isEmpty)
        
        let word = "Test"
        XCTAssertEqual(word.isNotEmpty, !word.isEmpty)
    }
    
    func testArrayDuplicateRemoval() throws {
        let array = [1,2,4,6,2,4]
        let uniqueArray = array
            .removeDuplicates()
            .sorted()
        XCTAssertEqual(uniqueArray, [1,2,4,6])
    }
    
    func testSafeIndexAccess() throws {
        let demo = [3,4,5,6,7,8,9,10]
        let thirdIndex = demo[safe: 3]
        XCTAssertNotNil(thirdIndex)
        XCTAssertEqual(thirdIndex, 6)
    }
}
