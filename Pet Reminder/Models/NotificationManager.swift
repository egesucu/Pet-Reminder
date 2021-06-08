//
//  NotificationManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//
//
//  NotificationManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.06.2019.
//  Copyright © 2019 Ege Sucu. All rights reserved.
//


import UserNotifications

class NotificationManager {
    
    static let notificationCenter = UNUserNotificationCenter.current()
    
    
    /**
     This method customizes Local notification for the need.
     
     - parameters:
        - date: Date for Notification
        - identifier: Type of Notification
        - name: Name of the pet ot be inserted into notification
 
     */
    static func createNotification(from date: Date,identifier: String, name: String){
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let day = calendar.component(.day, from: date)
        
        
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized{
                let notification = UNMutableNotificationContent()
                var dateComponents = DateComponents()
                
                switch identifier{
                    
                case "\(name)-morning-notification":
                    let morningTitle = NSLocalizedString("Morning-Title", comment: "Morning Notification Title")
                        
                    let morningContent = String.localizedStringWithFormat(NSLocalizedString("Morning-Content", comment: "Morning Notification Content"),name)
                    
                    
                    notification.title = morningTitle
                    notification.body = morningContent
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                    break
                case "\(name)-evening-notification":
                    let eveningTitle = NSLocalizedString("Evening-Title", comment: "Evening Notification Title")
                        
                    let eveningContent = String.localizedStringWithFormat(NSLocalizedString("Evening-Content", comment: "Evening Notification Content"),name)
                    
                    notification.title = eveningTitle
                    notification.body = eveningContent
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                    break
                    
                case "\(name)-birthday-notification":
                    let birthdayTitle = NSLocalizedString("Birthday-Title", comment: "Birthday Notification Title")
                    let birthdayContent = String.localizedStringWithFormat(NSLocalizedString("Birthday-Content", comment: "Evening Notification Content"),name)
                    
                    notification.title = birthdayTitle
                    notification.body = birthdayContent
                    
                    dateComponents.day = day
                    dateComponents.hour = 0
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    break
                default:
                    break
                }
                
                notification.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
                
                self.notificationCenter.add(request, withCompletionHandler: nil)
                
            }
        }
        
    }
    
    static func removeNotifications(identifiers: [String]){
        
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
        
    }
    
}
