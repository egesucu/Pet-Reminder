//
//  PetChangeViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Observation
import SwiftUI
import OSLog
import SwiftData
import Shared

@MainActor
@Observable
class PetChangeViewModel {

    var nameText = ""
    var petImage: Image?
    var birthday = Date()
    var selection: FeedSelection = .both
    var morningDate: Date = .eightAM
    var eveningDate: Date = .eightPM
    var showImagePicker = false
    var outputImageData: Data?
    var defaultPhotoOn = false
    var shouldChangeFeedSelection = false

    var notificationManager = NotificationManager()

    init () {}

    func loadImage(pet: Pet) {
        if let outputImageData {
            if let uiImage = UIImage(data: outputImageData) {
                petImage = Image(uiImage: uiImage)
            }
            pet.image = outputImageData
            defaultPhotoOn = false
        } else {
            outputImageData = nil
            defaultPhotoOn = true
        }
    }

    func deleteImageData(pet: Pet) async {
        pet.image = nil
        outputImageData = nil
    }

    func getPetData(pet: Pet) async {
        self.birthday = pet.birthday
        self.nameText = pet.name
        self.selection = pet.feedSelection ?? .both

        if let image = pet.image {
            self.outputImageData = image
            self.defaultPhotoOn = false
        } else {
            self.defaultPhotoOn = true
        }
    }

    func changeName(pet: Pet) async {
        pet.name = nameText
        await changeNotification(pet: pet, for: selection)
    }

    func changeBirthday(pet: Pet) async {
        pet.birthday = birthday
        notificationManager.removeNotification(of: pet.name, with: NotificationType.birthday)
        await notificationManager.createNotification(of: pet.name, with: NotificationType.birthday, date: birthday)
    }

    func changeNotification(pet: Pet, for selection: FeedSelection) async {
        pet.feedSelection = selection

        switch selection {
        case .both:
            notificationManager.removeAllDailyNotifications(of: pet.name)
            await notificationManager.createNotification(
                of: pet.name,
                with: NotificationType.morning,
                date: morningDate
            )
            await notificationManager.createNotification(
                of: pet.name,
                with: NotificationType.evening,
                date: eveningDate
            )
        case .morning:
            notificationManager.removeAllDailyNotifications(
                of: pet.name
            )
            await notificationManager.createNotification(
                of: pet.name,
                with: NotificationType.morning,
                date: morningDate
            )
        case .evening:
            notificationManager.removeAllDailyNotifications(
                of: pet.name
            )
            await notificationManager.createNotification(
                of: pet.name,
                with: NotificationType.evening,
                date: eveningDate
            )
        }
    }

    func removeImage() {
        outputImageData = nil
    }

    func cancelEditing(of pet: Pet?) {
        morningDate = .eightAM
        eveningDate = .eightPM
        guard let pet else { return }
        Task {
            await getPetData(pet: pet)
        }

    }

    func savePet(pet: Pet) async {
        await changeName(pet: pet)
        await changeBirthday(pet: pet)
        if defaultPhotoOn {
            await deleteImageData(pet: pet)
        } else {
            pet.image = outputImageData
        }
        await changeNotification(pet: pet, for: selection)

        morningDate = .eightAM
        eveningDate = .eightPM
    }

    func updateView(pet: Pet) {
        shouldChangeFeedSelection = false

        if let data = pet.image {
            outputImageData = data
        } else {
            outputImageData = nil
        }
    }

}
