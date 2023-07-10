//
//  AddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct AddPetView: View {

    @State private var manager = AddPetViewModel()
    @State private var showAlert = false
    @State private var customAlertText = ""
    @AppStorage(Strings.petSaved) var petSaved: Bool?
    @Environment(\.managedObjectContext) private var modelContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
        private var pets: FetchedResults<Pet>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack {
                PetNameTextField(name: $manager.name)
                    .padding(.bottom, 30)
                PetBirthdayView(birthday: $manager.birthday)
                PetImageView(selectedImageData: $manager.selectedImageData,
                             onImageDelete: manager.resetImageData)
                PetNotificationSelectionView(dayType: $manager.dayType,
                                             morningFeed: $manager.morningFeed,
                                             eveningFeed: $manager.eveningFeed)
                AddPetActionsView(name: $manager.name,
                                  onSave: checkPetName, onCancel: dismiss.callAsFunction)
            }
            .padding()
        }
        .alert(customAlertText, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                self.manager.name = ""
            }
        }
        .interactiveDismissDisabled(!manager.name.isEmpty)
        .sensoryFeedback(.alignment, trigger: true)
    }

    func showAlert(text: String) {
        self.customAlertText = text
        showAlert.toggle()
    }

    func checkPetName() {
        let filteredPets = pets.filter({ $0.name == manager.name })
        if filteredPets.count > 0 {
            showAlert(text: String(localized: "pet_name_found"))
        } else {
            manager.savePet(managedObjectContext: modelContext, onDismiss: dismiss.callAsFunction)
        }
    }
}

#Preview {
    let context = PersistenceController
        .preview
        .container
        .viewContext
    return AddPetView()
        .environment(\.managedObjectContext, context)
}
