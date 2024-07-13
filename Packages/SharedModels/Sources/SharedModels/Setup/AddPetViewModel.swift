//
//  AddPetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Observation
import SwiftData
import OSLog

@MainActor
@Observable
public class AddPetViewModel {

    public var dayType: FeedSelection = .both
    public var name = ""
    public var birthday: Date = .now
    public var morningFeed: Date = .eightAM
    public var eveningFeed: Date = .eightPM
    public var selectedImageData: Data?
    
    private let notificationManager: NotificationManager
    
    public init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }

    public func resetImageData() {
        selectedImageData = nil
    }

    public func savePet() async -> Pet {
        let pet = Pet(
            birthday: birthday,
            name: name,
            choice: 0,
            createdAt: .now,
            feedSelection: dayType,
            image: selectedImageData
        )
        await createNotifications()

        return pet
    }

    private func createNotifications() async {

        switch dayType {
        case .both:
            await notificationManager.createNotification(of: name, with: NotificationType.morning, date: morningFeed)
            await notificationManager.createNotification(of: name, with: NotificationType.evening, date: eveningFeed)
        case .morning:
            await notificationManager.createNotification(of: name, with: NotificationType.morning, date: morningFeed)
        case .evening:
            await notificationManager.createNotification(of: name, with: NotificationType.evening, date: eveningFeed)
        }

        await notificationManager.createNotification(of: name, with: .birthday, date: birthday)
    }

}
