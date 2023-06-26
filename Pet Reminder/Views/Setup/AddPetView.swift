//
//  AddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.09.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct AddPetView: View {

    @StateObject private var manager = AddPetViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext

    var petManager = PetManager.shared

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
                                  onSave: {
                    manager.savePet(petManager: petManager,
                                    onDismiss: dismiss.callAsFunction)
                }, onCancel: dismiss.callAsFunction)
            }
            .padding()
        }
        .interactiveDismissDisabled(!manager.name.isEmpty)
        .sensoryFeedback(.alignment, trigger: true)
    }
}

// swiftlint: disable type_name
struct AddPetView_Preview: PreviewProvider {
    static var previews: some View {
        AddPetView()
    }
}
// swiftlint: enable type_name
