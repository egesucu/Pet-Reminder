//
//  Pet_ReminderTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 8.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import XCTest
import SwiftData

// swiftlint: disable type_name
final class Pet_ReminderTests: XCTestCase {

    func testLanguageWithParameters() throws {
        let name = "Viski"
        let notExpectedOutput = "notification_content \(name)"
        let stringKey: String.LocalizationValue = "notification_content \(name)"
        let localization = String(localized: stringKey)
        XCTAssertTrue(localization != notExpectedOutput)
    }

}
// swiftlint: enable type_name
