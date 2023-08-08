//
//  PetChangeViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Observation
import SwiftUI

@Observable
class PetChangeViewModel {
    
    var nameText = ""
    var petImage: Image?
    var birthday = Date()
    var selection: FeedTimeSelection = .both
    var morningDate: Date = .now.eightAM()
    var eveningDate: Date = .now.eightPM()
    var showImagePicker = false
    var outputImageData: Data?
    var defaultPhotoOn = false
    
    var notificationManager = NotificationManager()
    
    
    func loadImage(pet: Pet) {
        if let outputImageData {
            if let uiImage = UIImage(data: outputImageData) {
                petImage = Image(uiImage: uiImage)
            }
            pet.image = outputImageData
            defaultPhotoOn = false
        } else {
            outputImageData = nil
            defaultPhotoOn = true
        }
    }
    
    func getPetData(pet: Pet) {
        self.birthday = pet.birthday ?? .now
        self.nameText = pet.name ?? ""
        self.selection = pet.selection
        if let morning = pet.morningTime {
            self.morningDate = morning
        }
        if let evening = pet.eveningTime {
            self.eveningDate = evening
        }
        
        if let image = pet.image {
            outputImageData = image
            defaultPhotoOn = false
        } else {
            defaultPhotoOn = true
        }
    }
    
    func changeName(pet: Pet) {
        pet.name = nameText
        changeNotification(pet: pet, for: selection)
    }
    
    func changeBirthday(pet: Pet) {
        pet.birthday = birthday
        notificationManager.removeNotification(of: pet.name ?? "", with: .birthday)
        notificationManager.createNotification(of: pet.name ?? "", with: .birthday, date: birthday)
    }
    
    func changeNotification(pet: Pet, for selection: FeedTimeSelection) {
        switch selection {
        case .both:
            notificationManager.removeNotification(of: pet.name ?? "", with: .morning)
            notificationManager.removeNotification(of: pet.name ?? "", with: .evening)
            notificationManager.createNotification(of: pet.name ?? "", with: .morning, date: morningDate)
            notificationManager.createNotification(of: pet.name ?? "", with: .evening, date: eveningDate)
        case .morning:
            notificationManager.removeNotification(of: pet.name ?? "", with: .morning)
            notificationManager.createNotification(of: pet.name ?? "", with: .morning, date: morningDate)
        case .evening:
            notificationManager.removeNotification(of: pet.name ?? "", with: .evening)
            notificationManager.createNotification(of: pet.name ?? "", with: .evening, date: eveningDate)
        }
        let (morningTime, eveningTime) = (pet.morningTime, pet.eveningTime)

        if morningTime != nil {
           pet.morningTime = morningDate
        }
        if eveningTime != nil {
            pet.eveningTime = eveningDate
        }
    }
    
}
