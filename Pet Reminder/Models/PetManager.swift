//
//  PetManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 14.05.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

class PetManager {

    static let shared = PetManager()
    let manager = NotificationManager.shared

    var name         = ""
    var birthday     = Date()
    var imageData: Data?
    var morningTime: Date?
    var eveningTime: Date?
    var selection    = NotificationSelection.both
    var pet: Pet?

    /// This function creates a Persistence Context to create a new Pet,
    /// transfers information that PetManager has been collecting from Setup Screens
    /// and sends the object to the persistence to save.
    func savePet(completion: () -> Void) {
        if let pet {
            saveNotifications(of: pet)
            completion()
        }
    }

    func saveNotifications(of pet: Pet) {
        if let morning = morningTime {
            manager.createNotification(of: pet.name ?? "", with: .morning, date: morning)
        }

        if let evening = eveningTime {
            manager.createNotification(of: pet.name ?? "", with: .evening, date: evening)
        }

        manager.createNotification(of: pet.name ?? "", with: .birthday, date: birthday)

    }

}
