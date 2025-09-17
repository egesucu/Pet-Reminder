//
//  NotificationManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import UserNotifications
import Observation
import OSLog
import Shared

extension UNNotificationRequest: @unchecked @retroactive Sendable {}
extension UNUserNotificationCenter: @unchecked @retroactive Sendable {}

/// A protocol defining the interface used by NotificationManager for notification handling.
/// This allows for easier testing and abstraction over UNUserNotificationCenter.
protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func pendingNotificationRequests() async -> [UNNotificationRequest]
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
}

extension UNUserNotificationCenter: NotificationCenterProtocol {}

/// Manages the scheduling, fetching, filtering, and removal of user notifications related to pets.
/// Uses the UserNotifications framework and observes notification requests for reactive updates.
@MainActor
@Observable
class NotificationManager {

    // MARK: - Types

    enum AuthorizationStatus: String {
        case authorized
        case denied
        case notDetermined
        case limited // provisional/ephemeral
    }

    // MARK: - Properties

    static let shared = NotificationManager()

    var notifications: [UNNotificationRequest] = .empty
    private let notificationCenter: any NotificationCenterProtocol

    // Exposed authorization snapshot for UI guidance (optional use in views)
    var lastKnownAuthorizationStatus: AuthorizationStatus = .notDetermined

    // MARK: - Initialization

    /// Initializes the NotificationManager with an optional notifications array and a notification center.
    /// - Parameters:
    ///   - notifications: Initial list of notifications.
    ///   - notificationCenter: The notification center to use. Defaults to UNUserNotificationCenter.current().
    private init(
        notifications: [UNNotificationRequest] = .empty,
        notificationCenter: any NotificationCenterProtocol = UNUserNotificationCenter.current()
    ) {
        self.notifications = notifications
        self.notificationCenter = notificationCenter
    }

    // MARK: - Permission & Fetch

    /// Refreshes and stores the current authorization status without prompting.
    func refreshAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        self.lastKnownAuthorizationStatus = Self.map(settings.authorizationStatus)
        Logger.notifications.info("Refreshed authorization status: \(self.lastKnownAuthorizationStatus.rawValue)")
    }

    /// Requests permission from the user to send notifications when status is not determined.
    /// If already authorized/denied, it does not prompt again.
    /// - Returns: A Boolean indicating if permission is (now) granted.
    func askPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                self.lastKnownAuthorizationStatus = granted ? .authorized : .denied
                return granted
            } catch {
                Logger.notifications.error("Authorization request failed: \(error.localizedDescription)")
                self.lastKnownAuthorizationStatus = .denied
                return false
            }
        case .denied:
            self.lastKnownAuthorizationStatus = .denied
            Logger.notifications.info("Notification authorization status is denied")
            return false
        case .provisional, .ephemeral:
            self.lastKnownAuthorizationStatus = .limited
            // Limited permissions are not suitable for repeating scheduled notifications; treat as not granted.
            return false
        case .authorized:
            self.lastKnownAuthorizationStatus = .authorized
            return true
        @unknown default:
            self.lastKnownAuthorizationStatus = .denied
            return false
        }
    }

    /// Filters notifications for a specific pet by checking if their identifiers contain the pet's name.
    /// - Parameter pet: The pet to filter notifications for.
    /// - Returns: An array of notifications related to the provided pet.
    func filterNotifications(of pet: Pet) -> [UNNotificationRequest] {
        notifications.filter { notification in
            Logger
                .notifications
                .info("Pet \(pet.name): notifications \(notification.identifier)")
            return notification.identifier.contains(pet.name)
        }
    }

    /// Fetches all pending notifications and updates the internal notifications list.
    func refreshNotifications() async {
        notifications = await notificationCenter.pendingNotificationRequests()
    }

    // MARK: - Notification Creation

    /// Creates notifications for a pet based on its feed selection and provided times.
    /// - Parameters:
    ///   - pet: The pet for which notifications should be created.
    ///   - morningTime: The morning notification time optional.
    ///   - eveningTime: The evening notification time optional.
    func createNotifications(for pet: Pet, morningTime: Date?, eveningTime: Date?) async {
        switch pet.feedSelection {
        case .both:
            await createNotificationSafely(of: pet.name, with: .morning, date: morningTime ?? .eightAM)
            await createNotificationSafely(of: pet.name, with: .evening, date: eveningTime ?? .eightPM)
            await createNotificationSafely(of: pet.name, with: .birthday, date: pet.birthday)
        case .morning:
            await createNotificationSafely(of: pet.name, with: .morning, date: morningTime ?? .eightAM)
            await createNotificationSafely(of: pet.name, with: .birthday, date: pet.birthday)
        case .evening:
            await createNotificationSafely(of: pet.name, with: .evening, date: eveningTime ?? .eightPM)
            await createNotificationSafely(of: pet.name, with: .birthday, date: pet.birthday)
        }
    }

    private func createNotificationSafely(of petName: String, with type: NotificationType, date: Date) async {
        do {
            try await createNotification(of: petName, with: type, date: date)
        } catch {
            Logger.notifications.error("Failed to create \(type.rawValue) notification for \(petName): \(error)")
        }
    }

    /// Changes the notification time for a specific pet and notification type.
    /// Removes the old notification and schedules a new one.
    /// - Parameters:
    ///   - petName: The pet's name.
    ///   - type: The type of notification.
    ///   - date: The new date/time for the notification.
    func changeNotificationTime(of petName: String, with type: NotificationType, date: Date) {
        Task {
            do {
                try await removeNotification(of: petName, with: type)
                try await createNotification(of: petName, with: type, date: date)
            } catch {
                Logger
                    .notifications
                    .error("Failed to change notification time for \(petName) type \(type.rawValue): \(error)")
            }
        }
    }
}

// MARK: - Notification Creation
extension NotificationManager {

    /// Creates a notification for a pet at a specified date and notification type.
    /// - Parameters:
    ///   - petName: The name of the pet.
    ///   - type: The notification type.
    ///   - date: The date for the notification.
    /// - Throws: Throws if permission is denied or adding the notification request fails.
    func createNotification(of petName: String, with type: NotificationType, date: Date) async throws {
        let granted = await askPermission()
        guard granted else {
            Logger.notifications.info(
                "Notification permission not granted; skipping scheduling for \(petName) \(type.rawValue)"
            )
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: .notificationTitle)
        var dateComponents = DateComponents()
        let calendar = Calendar.current

        switch type {
        case .birthday:
            content.body = String(localized: .notificationBirthdayContent(petName))
            dateComponents.day = calendar.component(.day, from: date)
            dateComponents.month = calendar.component(.month, from: date)
            dateComponents.hour = 0; dateComponents.minute = 0; dateComponents.second = 0
        default:
            content.body = String(localized: .notificationContent(petName))
            dateComponents.hour = calendar.component(.hour, from: date)
            dateComponents.minute = calendar.component(.minute, from: date)
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Strings.notificationIdentifier(
                petName,
                type.rawValue
            ),
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }
}

// MARK: - Notification Removal
extension NotificationManager {

    /// Removes all pending notifications that do not belong to any of the registered pets.
    /// - Parameter pets: The list of currently registered pets.
    /// - Throws: Placeholder for future error handling.
    func removeOtherNotifications(of pets: [Pet]) async throws {
        let allNotifications = await notificationCenter.pendingNotificationRequests()

        let namesSet = Set(pets.map(\.name))
        let allIdentifierSet = Set(allNotifications.map(\.identifier))

        let knownIdentifiers = allNotifications.compactMap { notification in
            namesSet.contains(where: { notification.identifier.contains($0) }) ? notification.identifier : nil
        }
        let knownIdentifierSet = Set(knownIdentifiers)

        let unknownIdentifiers = allIdentifierSet.subtracting(knownIdentifierSet)

        try await removeNotificationsIdentifiers(with: Array(unknownIdentifiers))
    }

    /// Removes notifications by their identifiers.
    /// - Parameter identifiers: The identifiers of notifications to remove.
    /// - Throws: Placeholder for future error handling.
    func removeNotificationsIdentifiers(with identifiers: [String]) async throws {
        // Currently, these calls do not throw, but method is async throws for future-proofing.
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    /// Removes the pending notification of a specific pet and notification type.
    /// - Parameters:
    ///   - petName: The name of the pet.
    ///   - type: The notification type to remove.
    /// - Throws: Placeholder for future error handling.
    func removeNotification(of petName: String, with type: NotificationType) async throws {
        try await removeNotificationsIdentifiers(with: [
            Strings.notificationIdentifier(petName, type.rawValue)
        ])
    }

    /// Removes all notifications (morning, evening, birthday) of a specific pet.
    /// - Parameter petName: The name of the pet. If nil, no action is taken.
    /// - Throws: Placeholder for future error handling.
    func removeAllNotifications(of petName: String?) async throws {
        guard let name = petName else { return }
        let notifications = Self.notificationIdentifiers(for: name, types: [.morning, .evening, .birthday])
        try await removeNotificationsIdentifiers(with: notifications)
    }

    /// Removes all daily notifications (morning and evening) of a specific pet.
    /// - Parameter petName: The name of the pet. If nil, no action is taken.
    /// - Throws: Placeholder for future error handling.
    func removeAllDailyNotifications(of petName: String?) async throws {
        guard let name = petName else { return }
        let notifications = Self.notificationIdentifiers(for: name, types: [.morning, .evening])
        try await removeNotificationsIdentifiers(with: notifications)
    }

    /// Removes all pending notifications of the app and then removes all notifications for each pet.
    /// - Parameter pets: The list of pets to remove notifications for.
    /// - Throws: Placeholder for future error handling.
    func removeNotifications(for pets: [Pet]) async throws {
        notificationCenter.removeAllPendingNotificationRequests()
        for pet in pets {
            try await removeAllNotifications(of: pet.name)
        }
    }

    /// Returns notification identifiers for a given pet name and notification types.
    /// - Parameters:
    ///   - name: The pet name.
    ///   - types: The notification types.
    /// - Returns: An array of notification identifiers.
    private static func notificationIdentifiers(for name: String, types: [NotificationType]) -> [String] {
        types.map { Strings.notificationIdentifier(name, $0.rawValue) }
    }

    // MARK: - Helpers

    private static func map(_ status: UNAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        case .provisional, .ephemeral: return .limited
        @unknown default: return .denied
        }
    }
}
