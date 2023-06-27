//
//  AddPetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

class AddPetViewModel: ObservableObject {

    @AppStorage(Strings.petSaved) var petSaved: Bool?

    @Environment(\.modelContext) var modelContext

    @Published var dayType: DayTime = .both
    @Published var name = ""
    @Published var birthday: Date = .now
    @Published var morningFeed: Date = Date().eightAM()
    @Published var eveningFeed: Date = Date().eightPM()
    @Published var selectedImageData: Data?

    func resetImageData() {
        selectedImageData = nil
    }

    func savePet(onDismiss: () -> Void) {
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
