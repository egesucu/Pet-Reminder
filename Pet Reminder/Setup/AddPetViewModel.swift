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

    let manager = NotificationManager()

    func resetImageData() {
        selectedImageData = nil
    }

    func savePet() async -> Pet {
        let pet = Pet()
        pet.createdAt = .now
        pet.birthday = birthday
        pet.name = name
        pet.birthday = birthday
        if let selectedImageData {
            pet.image = selectedImageData
        }
        switch dayType {
        case .morning:
            await createNotification(type: .morning)
            pet.morningTime = morningFeed
            pet.selection = .morning
        case .evening:
            await createNotification(type: .evening)
            pet.eveningTime = eveningFeed
            pet.selection = .evening
        case .both:
            await createNotification(type: .both)
            pet.morningTime = morningFeed
            pet.eveningTime = eveningFeed
            pet.selection = .both
        }
        return pet
    }

    private func createNotification(type: FeedTimeSelection) async {

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
