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

enum Selection: Int64 {
    case both
    case morning
    case evening
}

class PetManager{

    static let shared = PetManager()

    var name         : String  = ""
    var birthday     : Date    = Date()
    var imageData    : Data?   = nil
    var morningTime  : Date?   = nil
    var eveningTime  : Date?   = nil
    var selection    : Selection = .both
    
    
    func getName(name: String){
        self.name = name
        
    }
    
    func getBirthday(date: Date){
        self.birthday = date
    }
    
    func getSelection(selection: Selection){
        self.selection = selection
    }
    
    func getImage(image: UIImage? = nil){
        
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.5){
            self.imageData = imageData
        } else {
            self.imageData = nil
        }
        
    }
    
    func getDates(morning: Date?, evening: Date?) {
        if let morning = morning {
            self.morningTime = morning
        }
        
        if let evening = evening {
            self.eveningTime = evening
        }
    }
    
    func getChoice(selection: Selection) {
        self.selection = selection
    }
    
    func savePet(){
        
        let persistence = PersistenceController.shared
        
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
    
}

extension Pet{
    
    var selection: Selection {
        get{
            return Selection(rawValue: self.choice) ?? .both
        }
        set{
            choice = newValue.rawValue
        }
    }
}
