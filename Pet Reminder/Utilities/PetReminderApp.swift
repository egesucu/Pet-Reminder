//
//  PetReminderApp.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CloudKit
import SwiftData
import OSLog
import Shared

@main
struct PetReminderApp: App {
    @AppStorage(Strings.helloSeen) var helloSeen = false
    @Environment(\.undoManager) var undoManager
    @State private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            if helloSeen {
                HomeManagerView()
                    .environment(notificationManager)
                    .onAppear {
                        Task {
                            let result = await canUseCloudKit()
                            Logger().info("iCloud Availability: \(result)")
                        }
                    }
            } else {
                HelloView()
                    .environment(notificationManager)
            }
        }
        .modelContainer(for: Pet.self)
    }
    
    func isICloudAvailable() -> Bool {
        let ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken
        return ubiquityIdentityToken != nil
    }
    
    func checkCloudKitAvailability() async -> Bool {
        let container = CKContainer.default()
        do {
            let result = try await container.accountStatus()
            return result == .available ? true : false
        } catch let error {
            Logger().error("Error checking Container: \(error.localizedDescription)")
            return false
        }
        
    }
    
    func canUseCloudKit() async -> Bool {
        if isICloudAvailable() {
            return await checkCloudKitAvailability()
        } else {
            return false
        }
    }
}
