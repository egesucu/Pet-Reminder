//
//  PetDataManager.swift
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
class PetDataManager {

    enum PageState {
        case loading
        case loaded(pet: Pet)
        case failed
    }

    enum PhotoMode {
        case none
        case some(data: Data?)
    }

    var name = ""
    var birthday = Date()
    var selection: FeedSelection = .both
    var morningDate: Date = .eightAM
    var eveningDate: Date = .eightPM
    var showImagePicker = false
    var petType: PetType = .other

    var petImageData: Data?
    var petImage: UIImage?

    var notificationManager = NotificationManager.shared

    var pageState: PageState = .loading
    var photoMode: PhotoMode = .none

    var defaultSelected = false

    func removePhoto() {
        photoMode = .none
        petImageData = nil
        petImage = nil
    }

    func loadPet(for pet: Pet?, dismiss: @escaping () -> Void) {
        pageState = .loading
        guard let pet else {
            Logger().info("We need to have a pet data to work on this page")
            dismiss()
            return
        }

        self.birthday = pet.birthday
        self.name = pet.name
        self.selection = pet.feedSelection ?? .both
        self.petType = pet.type

        if let image = pet.image {
            petImageData = image
            self.photoMode = .some(data: image)
            self.loadImage()
            self.defaultSelected = false
        } else {
            self.photoMode = .none
            self.defaultSelected = true
        }

        pageState = .loaded(pet: pet)
    }

    func loadImage() {
        if let petImageData {
            petImage = UIImage(data: petImageData)
        }
    }

    func changeBirthday() async throws {
        switch pageState {
        case .loaded(let pet):
            try await notificationManager.removeNotification(
                of: pet.name,
                with: NotificationType.birthday
            )
            try await notificationManager.createNotification(
                of: pet.name,
                with: NotificationType.birthday,
                date: birthday
            )
        default:
            break
        }
    }

    func changeNotification() async throws {
        switch selection {
        case .both:
            try await notificationManager.removeAllDailyNotifications(of: name)
            try await notificationManager.createNotification(
                of: name,
                with: NotificationType.morning,
                date: morningDate
            )
            try await notificationManager.createNotification(
                of: name,
                with: NotificationType.evening,
                date: eveningDate
            )
        case .morning:
            try await notificationManager.removeAllDailyNotifications(
                of: name
            )
            try await notificationManager.createNotification(
                of: name,
                with: NotificationType.morning,
                date: morningDate
            )
        case .evening:
            try await notificationManager.removeAllDailyNotifications(
                of: name
            )
            try await notificationManager.createNotification(
                of: name,
                with: NotificationType.evening,
                date: eveningDate
            )
        }
    }

    func cancel(for pet: Pet) {
        morningDate = .eightAM
        eveningDate = .eightPM
        name = ""
        petImage = nil
        petImageData = nil
        birthday = .now
        selection = .both
        petType = .other

        loadPet(for: pet, dismiss: {})
    }

}
