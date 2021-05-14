//
//  PetManager.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 14.05.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

enum NotificationType{
    case morning, evening, both
}

class PetManager : ObservableObject {
    
    var name: String
    var birthday : Date
    var petImage : UIImage?
    var type : NotificationType
    
    init(){
        name = ""
        birthday = Date()
        petImage = nil
        type = .morning
    }
    
    static let petManager = PetManager()
    
    func saveNameAndBirthday(name: String,birthday: Date){
        
        self.name = name
        self.birthday = birthday
        
    }
    
    func saveImage(image: UIImage?){
        if let image = image{
            self.petImage = image
        }
    }
    
    func savePet(context: NSManagedObjectContext, morningTime: Date?,eveningTime: Date?) -> Bool{
        
        let newPet = Pet(context: context)
        newPet.id = UUID()
        newPet.name = self.name
        newPet.birthday = self.birthday
        
        if let image = self.petImage,
           let imageData = image.pngData()
        {
            newPet.image = imageData
        }
    
        switch self.type {
        case .morning:
            newPet.morningTime = morningTime
        case .evening:
            newPet.eveningTime = eveningTime
        default:
            newPet.morningTime = morningTime
            newPet.eveningTime = eveningTime
        }
        
        newPet.morningFed = false
        newPet.eveningFed = false
        
        do {
            try context.save()
            
            let petAvailable = UserDefaults.standard.bool(forKey: "petAvailable")
            
            if !petAvailable {
                UserDefaults.standard.setValue(true, forKey: "petAvailable")
            }
            
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
        
    }
    
}
