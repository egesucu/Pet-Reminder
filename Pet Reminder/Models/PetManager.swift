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
    }
    
    func saveNotification(){
        
        if let morning = morningTime {
            NotificationManager.createNotification(from: morning, identifier: .morning, name: self.name)
        }
        
        if let evening = eveningTime{
            NotificationManager.createNotification(from: evening, identifier: .evening, name: self.name)
        }
        
        NotificationManager.createNotification(from: birthday, identifier: .birthday, name: self.name)
        
        self.savePet()
    }
    
}
