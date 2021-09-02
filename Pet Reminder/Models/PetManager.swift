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
    func savePet(){
        let newPet = Pet(context: persistence.container.viewContext)
        newPet.id = UUID()
        newPet.name = self.name
        newPet.birthday = self.birthday
        newPet.morningTime = self.morningTime
        newPet.eveningTime = self.eveningTime
        newPet.image = self.imageData
        newPet.selection = selection
        
        persistence.save()
        
        saveNotifications(of: newPet)
    }
    
    func saveNotifications(of pet: Pet){
        
        
        if let morning = morningTime {
            manager.createNotification(of: pet, with: .morning, date: morning)
        }
        
        if let evening = eveningTime{
            manager.createNotification(of: pet, with: .evening, date: evening)
        }
        
        manager.createNotification(of: pet, with: .birthday, date: birthday)
        
    }
    
}
