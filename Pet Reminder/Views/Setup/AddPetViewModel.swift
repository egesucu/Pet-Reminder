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

@Observable
class AddPetViewModel {

    var dayType: FeedTimeSelection = .both
    var name = ""
    var birthday: Date = .now
    var morningFeed: Date = Date().eightAM()
    var eveningFeed: Date = Date().eightPM()
    // swiftlint: disable redundant_optional_initialization
    var selectedImageData: Data? = nil
    // swiftlint: enable redundant_optional_initialization

    let manager = NotificationManager.shared

    func resetImageData() {
        selectedImageData = nil
    }

    func savePet(modelContext: ModelContext, onDismiss: () -> Void) {
        let pet = Pet(name: name)
        pet.createdAt = .now
        pet.birthday = birthday
        pet.name = name
        pet.birthday = birthday
        if let selectedImageData {
            pet.image = selectedImageData
        }
        switch dayType {
        case .morning:
            createNotification(type: .morning)
            pet.morningTime = morningFeed
            pet.choice = .morning
        case .evening:
            createNotification(type: .evening)
            pet.eveningTime = eveningFeed
            pet.choice = .evening
        case .both:
            createNotification(type: .both)
            pet.morningTime = morningFeed
            pet.eveningTime = eveningFeed
            pet.choice = .both
        }

        modelContext.insert(pet)
        onDismiss()

    }

    private func createNotification(type: FeedTimeSelection) {

        switch type {
        case .both:
            manager.createNotification(of: name, with: NotificationType.morning, date: morningFeed)
            manager.createNotification(of: name, with: NotificationType.evening, date: eveningFeed)
        case .morning:
            manager.createNotification(of: name, with: NotificationType.morning, date: morningFeed)
        case .evening:
            manager.createNotification(of: name, with: NotificationType.evening, date: eveningFeed)
        }

        manager.createNotification(of: name, with: .birthday, date: birthday)
    }

}
