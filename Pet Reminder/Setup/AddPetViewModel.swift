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

@Observable
class AddPetViewModel {

    var dayType: FeedTimeSelection = .both
    var name = ""
    var birthday: Date = .now
    var morningFeed: Date = .eightAM
    var eveningFeed: Date = .eightPM
    var selectedImageData: Data?

    func resetImageData() {
        selectedImageData = nil
    }

    func savePet(notificationManager: NotificationManager) async -> Pet {
        let pet = Pet()
        pet.createdAt = .now
        pet.birthday = birthday
        pet.name = name
        pet.birthday = birthday
        pet.image = selectedImageData

        await createNotification(manager: notificationManager, type: dayType)
        pet.selection = dayType
        pet.morningTime = (dayType != .evening) ? morningFeed : nil
        pet.eveningTime = (dayType != .morning) ? eveningFeed : nil

        return pet
    }

    private func createNotification(
        manager: NotificationManager,
        type: FeedTimeSelection
    ) async {

        switch type {
        case .both:
            await manager.createNotification(of: name, with: NotificationType.morning, date: morningFeed)
            await manager.createNotification(of: name, with: NotificationType.evening, date: eveningFeed)
        case .morning:
            await manager.createNotification(of: name, with: NotificationType.morning, date: morningFeed)
        case .evening:
            await manager.createNotification(of: name, with: NotificationType.evening, date: eveningFeed)
        }

        await manager.createNotification(of: name, with: .birthday, date: birthday)
    }

}
