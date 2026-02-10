//
//  PetNameTextField.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import OSLog
import Shared

struct PetNameTextField: View {
    @Query var pets: [Pet]
    
    @Binding var addPet: AddPet

    @FocusState var isFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(.startNameLabel)
                .foregroundStyle(Color.label)
                .font(.title2)
                .bold()

            TextField(
                Strings.doggo,
                text: $addPet.name
            )
            .focused($isFocused)
            .foregroundStyle(Color.label)
            .font(.title)
            .padding()
            .autocorrectionDisabled()
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.words)
            .onChange(of: addPet.name) {
                check(name: addPet.name)
            }
            .task {
                check(name: addPet.name)
            }
            .background(
                Rectangle()
                    .fill(
                        isFocused ? .accent
                            .opacity(0.2) :
                            Color
                                .black
                                .opacity(0.1)

                    )
                    .animation(.easeInOut, value: isFocused)
                    .clipShape(.rect(cornerRadius: 10))
            )

            if addPet.petExists {
                Text(.petExists)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .bold()
            }

            Text(.petFact)
                .font(.footnote)
                .italic()
                .lineLimit(20)
        }
    }

    private func check(name: String) {
        let removedSpaceName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        Logger.pets.info("Name is: \(removedSpaceName)")

        addPet.nameIsValid = removedSpaceName.isNotEmpty

        guard removedSpaceName.isNotEmpty else {
            addPet.petExists = false
            return
        }

        let normalizedInput = removedSpaceName
            .folding(options: [.diacriticInsensitive, .widthInsensitive], locale: .current)
            .lowercased()

        addPet.petExists = pets.contains { existingPet in
            let normalizedExisting = existingPet.name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: [.diacriticInsensitive, .widthInsensitive], locale: .current)
                .lowercased()
            return normalizedExisting == normalizedInput
        }
    }
}

#if DEBUG

#Preview("Filled Case") {
    @Previewable @FocusState var isFocused: Bool
    @Previewable @State var addPet: AddPet = AddPet(name: "Horn")

    PetNameTextField(
        addPet: $addPet,
        isFocused: _isFocused
    )
    .padding(.all)
    .modelContainer(DataController.previewContainer)
    .onAppear {
        isFocused = true
    }
}

#Preview("Pet Exist Case") {
    @Previewable @State var addPet: AddPet = AddPet(name: Strings.viski)

    PetNameTextField(
        addPet: $addPet
    )
    .padding(.all)
    .modelContainer(DataController.previewContainer)
}

#Preview("Empty Case") {
    @Previewable @State var addPet: AddPet = .init()
    
    PetNameTextField(
        addPet: $addPet
    )
        .padding(.all)
        .modelContainer(DataController.previewContainer)
}

#endif
