import Foundation
import Shared
import Testing
import UserNotifications
@testable import Pet_Reminder

@MainActor
private final class ReminderCenter: NotificationCenterProtocol {
    var requests: [UNNotificationRequest] = []
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool { true }
    func pendingNotificationRequests() async -> [UNNotificationRequest] { requests }
    func add(_ request: UNNotificationRequest) async throws {
        requests.removeAll { $0.identifier == request.identifier }
        requests.append(request)
    }
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        requests.removeAll { identifiers.contains($0.identifier) }
    }
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) { }
    func removeAllPendingNotificationRequests() { requests.removeAll() }
}

@MainActor
struct ReminderEditingTests {
    @Test("Overlapping names keep filtering, deletion and cleanup isolated")
    func exactOwnership() async throws {
        let center = ReminderCenter()
        let manager = NotificationManager(notificationCenter: center, authorizationStatusProvider: { .authorized })
        let max = Pet(name: "Max")
        let maxine = Pet(name: "Maxine")
        for pet in [max, maxine] {
            for type in [NotificationType.morning, .evening, .birthday] {
                try await manager.createNotification(of: pet.name, with: type, date: .now)
            }
        }
        await manager.refreshNotifications()
        let matches = manager.filterNotifications(of: max)
        #expect(matches.count == 3)
        #expect(matches.allSatisfy { !$0.identifier.contains("Maxine") })
        try await manager.removeNotificationsIdentifiers(with: matches.map(\.identifier))
        #expect(center.requests.count == 3)
        try await manager.removeOtherNotifications(of: [max])
        #expect(center.requests.isEmpty)
    }

    @Test("Time-only edits are detected and custom times survive selection changes")
    func reminderTimes() async throws {
        let center = ReminderCenter()
        let notifications = NotificationManager(
            notificationCenter: center,
            authorizationStatusProvider: { .authorized }
        )
        let pet = Pet(name: "Max")
        let morning = try #require(Calendar.current.date(bySettingHour: 9, minute: 15, second: 0, of: .now))
        let evening = try #require(Calendar.current.date(bySettingHour: 21, minute: 30, second: 0, of: .now))
        try await notifications.createNotification(of: pet.name, with: .morning, date: morning)
        try await notifications.createNotification(of: pet.name, with: .evening, date: evening)
        let editor = PetDataManager(notificationManager: notifications)
        editor.loadPet(for: pet, dismiss: {})
        await editor.loadReminderTimes()
        #expect(!editor.scheduleChanged)
        #expect(editor.morningDate == morning)
        #expect(editor.eveningDate == evening)
        editor.morningDate = morning.addingTimeInterval(30 * 60)
        #expect(editor.scheduleChanged)
        await editor.changeNotification()
        let changed = await notifications.scheduledTime(for: pet.name, type: .morning)
        #expect(changed == editor.morningDate)
        editor.selection = .evening
        await editor.changeNotification()
        let preserved = await notifications.scheduledTime(for: pet.name, type: .evening)
        #expect(preserved == evening)
        #expect(center.requests.count == 1)
    }

    @Test("Renaming rejects blanks and normalized duplicates but allows the same pet")
    func nameValidation() {
        let pet = Pet(name: "Max")
        let other = Pet(name: "Café")
        let editor = PetDataManager()
        for invalid in ["   ", " CAFE ", "café"] {
            editor.name = invalid
            #expect(!editor.nameCanBeSaved(for: pet, among: [pet, other]))
        }
        editor.name = " MAX "
        #expect(editor.nameCanBeSaved(for: pet, among: [pet, other]))
    }
}
