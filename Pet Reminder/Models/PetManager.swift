//
//  PetManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 14.05.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

class PetManager{

    static let shared = PetManager()
    let persistence = PersistenceController.shared
    let manager = NotificationManager.shared

    var name         = ""
    var birthday     = Date()
    var imageData    : Data?
    var morningTime  : Date?
    var eveningTime  : Date?
    var selection    = Selection.both
    
    
    /// This function creates a Persistence Context to create a new Pet, transfers information that PetManager has been collecting from Setup Screens
    /// and sends the object to the persistence to save.
    func savePet(completion: () -> Void){
        let newPet = Pet(context: persistence.container.viewContext)
        newPet.id = UUID()
        newPet.name = name
        newPet.birthday = birthday
        newPet.morningTime = morningTime
        newPet.eveningTime = eveningTime
        newPet.image = imageData
        newPet.selection = selection
        
        persistence.save()
        
        saveNotifications(of: newPet)
        completion()
    }
    
    func saveNotifications(of pet: Pet){
        if let morning = morningTime {
            manager.createNotification(of: pet.name ?? "", with: .morning, date: morning)
        }
        
        if let evening = eveningTime{
            manager.createNotification(of: pet.name ?? "", with: .evening, date: evening)
        }
        
        manager.createNotification(of: pet.name ?? "", with: .birthday, date: birthday)
        
    }
    
}
