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

@Observable
class NotificationManager {

    let notificationCenter = UNUserNotificationCenter.current()

    func accessRequest(completion: @escaping (Bool, Error?) -> Void) {
        notificationCenter
            .requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: completion
            )
    }

    func filterNotifications(of pet: Pet) -> [UNNotificationRequest] {
        notifications.filter { notification in
            print(notification.identifier)
            return notification.identifier.contains(pet.wrappedName)
        }
    }

    var notifications: [UNNotificationRequest] = .empty

    func getNotifications() async {
        notifications = await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    func changeNotificationTime(of petName: String, with date: Date, for type: NotificationType) {
        removeNotification(of: petName, with: type)
        createNotification(of: petName, with: type, date: date)
    }

    func checkAllAppNotifications() async {
        notifications = await notificationCenter.pendingNotificationRequests()
    }

}

// MARK: - ADD NOTIFICATIONS
extension NotificationManager {

    func createNotification(of petName: String, with type: NotificationType, date: Date) {
        accessRequest { _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                let content = UNMutableNotificationContent()
                content.title = String(localized: "notification_title")
                var dateComponents = DateComponents()
                let calendar = Calendar.current

                switch type {
                case .birthday:
                    content.body = String(localized: "notification_birthday_content \(petName)")
                    dateComponents.day = calendar.component(.day, from: date)
                    dateComponents.month = calendar.component(.month, from: date)
                    dateComponents.year = calendar.component(
                        .year,
                        from: calendar.date(
                            byAdding: .year,
                            value: 1,
                            to: date
                        ) ?? .now
                    )
                    dateComponents.hour = 0; dateComponents.minute = 0; dateComponents.second = 0
                default:
                    content.body = String(localized: "notification_content \(petName)")
                    dateComponents.hour = calendar.component(.hour, from: date)
                    dateComponents.minute = calendar.component(.minute, from: date)
                }
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(
                    identifier: Strings.notificationIdenfier(
                        petName,
                        type.rawValue
                    ),
                    content: content,
                    trigger: trigger
                )

                self.notificationCenter.add(request) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

// MARK: - DELETING NOTIFICATIONS
extension NotificationManager {
    /// Checks all pending notifications that does not belong any registered pets and removes them.
    /// - Parameter names: Names of the registered pets.
    func removeOtherNotifications(beside names: [String]) {
        notificationCenter.getPendingNotificationRequests { requests in
            var identifiers = requests.compactMap { $0.identifier }
            names.forEach { name in
                identifiers = identifiers.filter({ !($0.contains(name))})
            }
            self.removeNotificationsIdentifiers(with: identifiers)
        }
    }

    func removeNotificationsIdentifiers(with identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func removeNotification(of petName: String, with type: NotificationType) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            Strings.notificationIdenfier(petName, type.rawValue)])
    }

    func removeAllNotifications(of petName: String?) {
        guard let name = petName else { return }
        let notifications = [
            Strings.notificationIdenfier(name, NotificationType.morning.rawValue),
            Strings.notificationIdenfier(name, NotificationType.evening.rawValue),
            Strings.notificationIdenfier(name, NotificationType.birthday.rawValue)
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notifications)
    }

    func removeNotifications(pets: [Pet]) {
        notificationCenter.removeAllPendingNotificationRequests()
        for pet in pets {
            switch pet.selection {
            case .both:
                createNotification(of: pet.wrappedName, with: .morning, date: pet.eveningTime ?? .now)
                createNotification(of: pet.wrappedName, with: .evening, date: pet.morningTime ?? .now)
            case .evening:
                createNotification(of: pet.wrappedName, with: .evening, date: pet.morningTime ?? .now)
            case .morning:
                createNotification(of: pet.wrappedName, with: .morning, date: pet.eveningTime ?? .now)
            }
            createNotification(of: pet.wrappedName, with: .birthday, date: pet.wrappedBirthday)
        }
    }
}
