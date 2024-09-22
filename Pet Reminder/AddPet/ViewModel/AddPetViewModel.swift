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
class AddPetViewModel {

    var dayType: FeedSelection = .both
    var name = ""
    var birthday: Date = .now
    var morningFeed: Date = .eightAM
    var eveningFeed: Date = .eightPM
    var selectedImageData: Data?
    var petType: PetType = .dog
    
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }

    func resetImageData() {
        selectedImageData = nil
    }

    func savePet() async -> Pet {
        let pet = Pet(
            birthday: birthday,
            name: name,
            choice: 0,
            createdAt: .now,
            feedSelection: dayType,
            image: selectedImageData,
            type: petType
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
