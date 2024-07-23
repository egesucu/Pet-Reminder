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

@MainActor
@Observable
public class PetChangeViewModel {

    public var nameText = ""
    public var petImage: Image?
    public var birthday = Date()
    public var selection: FeedSelection = .both
    public var morningDate: Date = .eightAM
    public var eveningDate: Date = .eightPM
    public var showImagePicker = false
    public var outputImageData: Data?
    public var defaultPhotoOn = false
    public var shouldChangeFeedSelection = false

    public var notificationManager = NotificationManager()
    
    public init () {}

    public func loadImage(pet: Pet) {
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

    public func deleteImageData(pet: Pet) async {
        pet.image = nil
        outputImageData = nil
    }

    @MainActor
    public func getPetData(pet: Pet) async {
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

    public func changeName(pet: Pet) async {
        pet.name = nameText
        await changeNotification(pet: pet, for: selection)
    }

    public func changeBirthday(pet: Pet) async {
        pet.birthday = birthday
        notificationManager.removeNotification(of: pet.name, with: .birthday)
        await notificationManager.createNotification(of: pet.name, with: .birthday, date: birthday)
    }

    public func changeNotification(pet: Pet, for selection: FeedSelection) async {
        pet.feedSelection = selection

        switch selection {
        case .both:
            notificationManager.removeAllDailyNotifications(of: pet.name)
            await notificationManager.createNotification(of: pet.name, with: .morning, date: morningDate)
            await notificationManager.createNotification(of: pet.name, with: .evening, date: eveningDate)
        case .morning:
            notificationManager.removeAllDailyNotifications(of: pet.name)
            await notificationManager.createNotification(of: pet.name, with: .morning, date: morningDate)
        case .evening:
            notificationManager.removeAllDailyNotifications(of: pet.name)
            await notificationManager.createNotification(of: pet.name, with: .evening, date: eveningDate)
        }
    }

    public func removeImage() {
        outputImageData = nil
    }

    public func cancelEditing(of pet: Pet?) {
        morningDate = .eightAM
        eveningDate = .eightPM
        guard let pet else { return }
        Task {
            await getPetData(pet: pet)
        }

    }

    public func savePet(pet: Pet) async {
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

    public func updateView(pet: Pet) {
        shouldChangeFeedSelection = false

        if let data = pet.image {
            outputImageData = data
        } else {
            outputImageData = nil
        }
    }

}
