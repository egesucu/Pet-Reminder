//
//  NotificationManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import UserNotifications

enum NotificationType: String{
    case morning
    case evening
    case birthday
}

class NotificationManager{
    
    static let shared = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    func accessRequest(completion: @escaping (Bool,Error?) -> (Void)){
        notificationCenter.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: completion)
    }
    
    func createNotification(of pet: Pet, with type: NotificationType, date: Date){
        
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
                    content.body = String.localizedStringWithFormat(NSLocalizedString("notification_birthday_content", comment: "Pet's name with birthday content"), pet.name ?? "")
                    dateComponents.day = calendar.component(.day, from: date)
                    dateComponents.month = calendar.component(.month, from: date)
                    dateComponents.hour = 0; dateComponents.minute = 0; dateComponents.second = 0
                default:
                    content.body = String.localizedStringWithFormat(NSLocalizedString("notification_content", comment: "Pet's name with content"), pet.name ?? "")
                    dateComponents.hour = calendar.component(.hour, from: date)
                    dateComponents.minute = calendar.component(.minute, from: date)
                }
                
                if let name = pet.name{
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "\(name)-\(type.rawValue)-notification", content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func removeNotification(of pet: Pet, with type: NotificationType){
        if let name = pet.name{
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(name)-\(type.rawValue)-notification"])
        }
    }
    
    func removeAllNotifications(of pet: Pet){
        guard let name = pet.name else { return }
        let notifications = [
            name + "-morning-notification",
            name + "-evening-notification",
            name + "-birthday-notification"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notifications)
    }
    
    func changeNotificationTime(of pet: Pet, with date: Date, for type: NotificationType){
        removeAllNotifications(of: pet)
        createNotification(of: pet, with: type, date: date)
        
    }
}
