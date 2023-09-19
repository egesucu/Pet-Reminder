//
//  Pet_ReminderTests.swift
//  Pet ReminderTests
//
//  Created by Ege Sucu on 8.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import XCTest
import CoreData
@testable import Pet_Reminder

// swiftlint: disable type_name
final class Pet_ReminderTests: XCTestCase {

    func testLanguageWithParameters() throws {
        let name = "Viski"
        let notExpectedOutput = "notification_content \(name)"
        let stringKey: String.LocalizationValue = "notification_content \(name)"
        let localization = String(localized: stringKey)
        XCTAssertTrue(localization != notExpectedOutput)
    }
    
    func testOtherNotificationDeletion() async throws {
        let notificationManager = NotificationManager()
        
        let fetchRequest: NSFetchRequest<Pet> = Pet.fetchRequest()
        let context = PersistenceController.preview.container.viewContext
        let pets = try context.fetch(fetchRequest)
        
        for pet in pets {
            await notificationManager.createNotifications(for: pet)
        }
        
        await notificationManager.createNotification(of: "Bud", with: .morning, date: .now)
        await notificationManager.createNotification(of: "Bud", with: .evening, date: .now)
        await notificationManager.createNotification(of: "Bud", with: .birthday, date: .now)
        
        
        await notificationManager.removeOtherNotifications(of: pets)
        
        async let notifications = notificationManager.notificationCenter.pendingNotificationRequests()
        let identifiers = await notifications.map(\.identifier)
        
        XCTAssertFalse(identifiers.contains("Bud"))
    }

}
// swiftlint: enable type_name
