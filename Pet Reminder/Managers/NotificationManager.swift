//
//  NotificationManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject{
    
    static let shared = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    func accessRequest(completion: @escaping (Bool,Error?) -> (Void)){
        notificationCenter.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: completion)
    }
    
    @Published var notifications : [UNNotificationRequest] = .empty
    
    func getNotifications(){
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.notifications = requests
            }
        }
    }
    
    func changeNotificationTime(of petName: String, with date: Date, for type: NotificationType){
        removeNotification(of: petName, with: type)
        createNotification(of: petName, with: type, date: date)
    }
    
    func checkAllAppNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            for request in requests {
                print(request.identifier)
            }
        }
    }
    
}

// MARK: - ADD NOTIFICATIONS
extension NotificationManager{
    
    func createNotification(of petName: String, with type: NotificationType, date: Date){
        accessRequest { success, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("notification_title", comment: "Notification Title")
                var dateComponents = DateComponents()
                let calendar = Calendar.current
                
                switch type {
                case .birthday:
                    content.body = String.localizedStringWithFormat(NSLocalizedString("notification_birthday_content", comment: "Pet's name with birthday content"), petName)
                    dateComponents.day = calendar.component(.day, from: date)
                    dateComponents.month = calendar.component(.month, from: date)
                    dateComponents.year = calendar.component(.year, from: calendar.date(byAdding: .year, value: 1, to: date) ?? .now)
                    dateComponents.hour = 0; dateComponents.minute = 0; dateComponents.second = 0
                default:
                    content.body = String.localizedStringWithFormat(NSLocalizedString("notification_content", comment: "Pet's name with content"), petName)
                    dateComponents.hour = calendar.component(.hour, from: date)
                    dateComponents.minute = calendar.component(.minute, from: date)
                }
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "\(petName)-\(type.rawValue)-notification", content: content, trigger: trigger)
                
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
extension NotificationManager{
    func removeOtherNotifications(beside names: [String]){
        notificationCenter.getPendingNotificationRequests { requests in
            var identifiers = requests.compactMap{ $0.identifier }
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
    
    func removeNotification(of petName: String, with type: NotificationType){
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(petName)-\(type.rawValue)-notification"])
    }
    
    func removeAllNotifications(of petName: String?){
        guard let name = petName else { return }
        let notifications = [
            name + "-morning-notification",
            name + "-evening-notification",
            name + "-birthday-notification"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notifications)
    }
    
    func removeNotifications(pets: [Pet]){
        notificationCenter.removeAllPendingNotificationRequests()
        for pet in pets {
            switch pet.selection{
            case .both:
                createNotification(of: pet.name ?? "", with: .morning, date: pet.eveningTime ?? .now)
                createNotification(of: pet.name ?? "", with: .evening, date: pet.morningTime ?? .now)
            case .evening:
                createNotification(of: pet.name ?? "", with: .evening, date: pet.morningTime ?? .now)
            case .morning:
                createNotification(of: pet.name ?? "", with: .morning, date: pet.eveningTime ?? .now)
            }
            createNotification(of: pet.name ?? "", with: .birthday, date: pet.birthday ?? .now)
        }
    }
}
