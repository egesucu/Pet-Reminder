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

class PetManager{

    static let petManager = PetManager()
    
    private let tempPet = Pet()
    
    func getName(name: String){
        tempPet.name = name
        
    }
    
    func getImage(image: UIImage? = nil){
        
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.5){
            tempPet.image = imageData
        } else {
            tempPet.image = UIImage(named: "default-animal")?.jpegData(compressionQuality: 0.5) ?? Data()
        }
        
    }
    
    func getBirthday(date: Date){
        tempPet.birthday = date
    }
    
    func getDates(morning: Date?, evening: Date?) {
        if let morning = morning {
            tempPet.morningTime = morning
        }
        
        if let evening = evening {
            tempPet.eveningTime = evening
        }
    }
    
    func savePet(context: NSManagedObjectContext){
        
        let newPet = Pet(context: context)
        newPet.name = tempPet.name
        newPet.birthday = tempPet.birthday
        newPet.morningTime = tempPet.morningTime
        newPet.eveningTime = tempPet.eveningTime
        newPet.image = tempPet.image
        
        do {
            try context.save()
            
            var petCount = UserDefaults.standard.integer(forKey: "petCount")
            petCount += 1
            UserDefaults.standard.set(petCount, forKey: "petCount")
            
        } catch let error{
            print("There is an error: \(error), with description: \(error.localizedDescription)")
        }
        
    }
    
}
