//
//  AddPetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Observation
import SwiftData

@Observable
class AddPetViewModel {

    var dayType: DayTime = .both
    var name = ""
    var birthday: Date = .now
    var morningFeed: Date = Date().eightAM()
    var eveningFeed: Date = Date().eightPM()
    // swiftlint: disable redundant_optional_initialization
    var selectedImageData: Data? = nil
    // swiftlint: enable redundant_optional_initialization

    func resetImageData() {
        selectedImageData = nil
    }

    func savePet(modelContext: ModelContext, onDismiss: () -> Void) {
        let pet = Pet(name: name)
        pet.birthday = birthday
        pet.name = name
        pet.birthday = birthday
        if let selectedImageData {
            pet.image = selectedImageData
        }
//        switch dayType {
//        case .morning:
//            pet.morningTime = morningFeed
//            pet.choice = .morning
//        case .evening:
//            pet.eveningTime = eveningFeed
//            pet.choice = .evening
//        case .both:
//            pet.morningTime = morningFeed
//            pet.eveningTime = eveningFeed
//            pet.choice = .both
//        }

        do {
            try modelContext.save()
            onDismiss()
        } catch let error {
            print(error)
        }

    }

}
