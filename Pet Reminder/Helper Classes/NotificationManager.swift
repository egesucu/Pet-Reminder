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
                case .morning:
                    content.body = NSLocalizedString("notification_content_\(pet.name ?? "")", comment: "Pet's name with content")
                    dateComponents.hour = calendar.component(.hour, from: date)
                    dateComponents.minute = calendar.component(.minute, from: date)
                case .evening:
                    content.body = NSLocalizedString("notification_content_\(pet.name ?? "")", comment: "Pet's name with content")
                    dateComponents.hour = calendar.component(.hour, from: date)
                    dateComponents.minute = calendar.component(.minute, from: date)
                case .birthday:
                    content.body = NSLocalizedString("notification_birthday_content_\(pet.name ?? "")", comment: "Pet's name with birthday content")
                    dateComponents.day = calendar.component(.day, from: date)
                    dateComponents.month = calendar.component(.month, from: date)
                    dateComponents.hour = 0
                    dateComponents.minute = 0
                    dateComponents.second = 0
                }
                
                if let id = pet.id{
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "\(id.uuidString)-\(type.rawValue)-notification", content: content, trigger: trigger)
                    
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
        if let id = pet.id{
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(id.uuidString)-\(type.rawValue)-notification"])
        }
        
    }
    
    func removeAllNotifications(of pet: Pet){
        guard let id = pet.id else { return }
        let notifications = [
            id.uuidString + "-morning-notification",
            id.uuidString + "-evening-notification",
            id.uuidString + "-birthday-notification"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notifications)
        
    }
    
    func changeNotificationTime(of pet: Pet, with date: Date, for type: NotificationType){
        
        removeAllNotifications(of: pet)
        createNotification(of: pet, with: type, date: date)
        
    }
}
