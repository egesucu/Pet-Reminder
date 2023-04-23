//
//  AddPetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

class AddPetViewModel: ObservableObject {
    
    @AppStorage("petSaved") var petSaved : Bool?
    
    @Published var dayType : DayTime = .both
    @Published var name = ""
    @Published var birthday : Date = .now
    @Published var morningFeed : Date = Date().eightAM()
    @Published var eveningFeed : Date = Date().eightPM()
    @Published var selectedImageData: Data? = nil
    
    
    func resetImageData() {
        selectedImageData = nil
    }
    
    func savePet(petManager: PetManager, onDismiss: () -> ()){
        petManager.name = name
        petManager.birthday = birthday
        if let selectedImageData {
            petManager.imageData = selectedImageData
        }
        switch dayType {
        case .morning:
            petManager.morningTime = morningFeed
            petManager.selection = .morning
        case .evening:
            petManager.eveningTime = eveningFeed
            petManager.selection = .evening
        case .both:
            petManager.morningTime = morningFeed
            petManager.eveningTime = eveningFeed
            petManager.selection = .both
        }
        
        petManager.savePet() {
            petSaved = true
            onDismiss()
        }
    }
    
    
    
}
