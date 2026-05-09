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
    
    @Binding var model: AddPet.Model

    @FocusState var isFocused

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text(.startNameLabel)
                .foregroundStyle(Color.label)
                .font(.title2)
                .bold()

            TextField(
                Strings.doggo,
                text: $model.name
            )
            .focused($isFocused)
            .foregroundStyle(Color.label)
            .font(.title)
            .padding()
            .autocorrectionDisabled()
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.words)
            .onChange(of: model.name) {
                check(name: model.name)
            }
            .task {
                check(name: model.name)
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
                    .clipShape(.rect(cornerRadius: .radius10))
            )

            if model.petExists {
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

        model.nameIsValid = removedSpaceName.isNotEmpty

        guard removedSpaceName.isNotEmpty else {
            model.petExists = false
            return
        }

        let normalizedInput = removedSpaceName
            .folding(options: [.diacriticInsensitive, .widthInsensitive], locale: .current)
            .lowercased()

        model.petExists = pets.contains { existingPet in
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
    @Previewable @State var model: AddPet.Model = AddPet.Model(name: "Horn")

    PetNameTextField(
        model: $model,
        isFocused: _isFocused
    )
    .padding(.all)
    .modelContainer(DataController.previewContainer)
    .onAppear {
        isFocused = true
    }
}

#Preview("Pet Exist Case") {
    @Previewable @State var model: AddPet.Model = AddPet.Model(name: Strings.viski)

    PetNameTextField(
        model: $model
    )
    .padding(.all)
    .modelContainer(DataController.previewContainer)
}

#Preview("Empty Case") {
    @Previewable @State var model: AddPet.Model = .init()
    
    PetNameTextField(
        model: $model
    )
        .padding(.all)
        .modelContainer(DataController.previewContainer)
}

#endif
