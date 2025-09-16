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

    var petImageData: Data? {
        didSet {
            // Optional: downsample/compress large images before keeping them in memory/storage
            if let data = petImageData,
               let processed = ImageDownsampling.downsampleIfNeeded(data: data, maxDimension: 1024, jpegQuality: 0.8) {
                petImageData = processed
            }
        }
    }
    var petImage: UIImage?

    var notificationManager = NotificationManager.shared

    var pageState: PageState = .loading
    var photoMode: PhotoMode = .none

    var defaultSelected = false

    // Simple error surface for UI (alerts/toasts)
    var lastErrorMessage: String?

    func removePhoto() {
        photoMode = .none
        petImageData = nil
        petImage = nil
    }

    func loadPet(for pet: Pet?, dismiss: @escaping () -> Void) {
        pageState = .loading
        guard let pet else {
            Logger.pets.error("We need to have a pet data to work on this page")
            pageState = .failed
            dismiss()
            return
        }

        self.birthday = pet.birthday
        self.name = pet.name
        self.selection = pet.feedSelection
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
            if let decoded = UIImage(data: petImageData) {
                petImage = decoded
            } else {
                Logger.pets.error("Failed to decode image data for pet")
                // Clear invalid data to avoid repeated failures
                petImage = nil
                self.petImageData = nil
                photoMode = .none
            }
        } else {
            petImage = nil
        }
    }

    func changeBirthday() async {
        switch pageState {
        case .loaded(let pet):
            do {
                try await notificationManager.removeNotification(
                    of: pet.name,
                    with: NotificationType.birthday
                )
                try await notificationManager.createNotification(
                    of: pet.name,
                    with: NotificationType.birthday,
                    date: birthday
                )
            } catch {
                Logger.notifications.error(
                    "Failed to update birthday notification for \(pet.name): \(error.localizedDescription)"
                )
                lastErrorMessage = String(localized: .notificationBirthdayUpdateFailed)
                pageState = .failed
            }
        default:
            break
        }
    }

    func changeNotification() async {
        do {
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
                try await notificationManager.removeAllDailyNotifications(of: name)
                try await notificationManager.createNotification(
                    of: name,
                    with: NotificationType.morning,
                    date: morningDate
                )
            case .evening:
                try await notificationManager.removeAllDailyNotifications(of: name)
                try await notificationManager.createNotification(
                    of: name,
                    with: NotificationType.evening,
                    date: eveningDate
                )
            }
        } catch {
            Logger.notifications.error(
                "Failed to update daily notifications for \(self.name): \(error.localizedDescription)"
            )
            lastErrorMessage = String(localized: .notificationDailyUpdateFailed)
            pageState = .failed
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
        showImagePicker = false
        defaultSelected = false
        photoMode = .none
        lastErrorMessage = nil

        loadPet(for: pet, dismiss: {})
    }

}
