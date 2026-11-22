//
//  PetDataManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Reminders
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

    var name = String.empty
    var breed = String.empty
    var birthday = Date()
    var selection: FeedSelection = .both
    var morningDate: Date = .eightAM
    var eveningDate: Date = .eightPM
    var kind: Kind = .other

    var petImageData: Data?

    let notificationManager: NotificationManager
    private var initialMorningDate: Date = .eightAM
    private var initialEveningDate: Date = .eightPM
    private var initialSelection: FeedSelection = .both

    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }

    var scheduleChanged: Bool {
        selection != initialSelection
            || !Calendar.current.isDate(morningDate, equalTo: initialMorningDate, toGranularity: .minute)
            || !Calendar.current.isDate(eveningDate, equalTo: initialEveningDate, toGranularity: .minute)
    }

    func loadReminderTimes() async {
        morningDate = await notificationManager.scheduledTime(for: name, type: .morning) ?? .eightAM
        eveningDate = await notificationManager.scheduledTime(for: name, type: .evening) ?? .eightPM
        initialMorningDate = morningDate
        initialEveningDate = eveningDate
        initialSelection = selection
    }

    func nameCanBeSaved(for pet: Pet, among pets: [Pet]) -> Bool {
        let cleaned = Pet.cleanedName(for: name)
        return !cleaned.isEmpty && !pets.contains {
            $0.persistentModelID != pet.persistentModelID && $0.hasNameMatching(cleaned)
        }
    }

    var pageState: PageState = .loading

    var defaultSelected = false

    // Simple error surface for UI (alerts/toasts)
    var lastErrorMessage: String?

    func removePhoto() {
        petImageData = nil
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
        self.breed = pet.breed ?? String.empty
        self.kind = pet.kind

        petImageData = pet.image
        defaultSelected = pet.image == nil
        pageState = .loaded(pet: pet)
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
                lastErrorMessage = String(localized: SharedStrings.notificationBirthdayUpdateFailed)
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
            lastErrorMessage = String(localized: SharedStrings.notificationDailyUpdateFailed)
        }
    }

    func cancel(for pet: Pet) {
        morningDate = .eightAM
        eveningDate = .eightPM
        name = .empty
        petImageData = nil
        birthday = .now
        selection = .both
        kind = .other
        defaultSelected = false
        lastErrorMessage = nil

        loadPet(for: pet, dismiss: {})
    }

}
