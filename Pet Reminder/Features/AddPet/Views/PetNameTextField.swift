//
//  PetNameTextField.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared

struct PetNameTextField: View {
    @Query(sort: \Pet.name) var pets: [Pet]

    @Binding var name: String
    @State private var showAlert = false
    @Binding var nameIsValid: Bool
    @Binding var petExists: Bool

    @FocusState var isFocused

    var body: some View {
        VStack(alignment: .leading) {
            Text(.startNameLabel)
                .foregroundStyle(Color.label)
                .font(.title2)
                .bold()
                .padding(.bottom, 20)

            TextField(
                Strings.doggo,
                text: $name
            )
            .focused($isFocused)
            .foregroundStyle(Color.label)
            .font(.title)
            .padding()
            .autocorrectionDisabled()
            .multilineTextAlignment(.center)
            .onChange(of: name) {
                check(name: name)
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

            if petExists {
                Text(.petExists)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .bold()
            }
        }
    }

    private func check(name: String) {
        let removedSpaceName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        Logger.pets.info("Name is: \(removedSpaceName)")
        if removedSpaceName.isNotEmpty {
            nameIsValid = true
        } else {
            nameIsValid = false
        }

        self.petExists = pets.map(\.name).contains(name)
    }
}

#if DEBUG

#Preview("Filled Case") {
    @Previewable @FocusState var isFocused: Bool

    PetNameTextField(
        name: .constant(Strings.viski),
        nameIsValid: .constant(false),
        petExists: .constant(false),
        isFocused: _isFocused
    )
    .padding(.all)
    .modelContainer(DataController.previewContainer)
    .background(.ultraThinMaterial)
    .padding()
    .onAppear {
        isFocused = true
    }
}

#Preview("Empty Case") {
    PetNameTextField(
        name: .constant(""),
        nameIsValid: .constant(false),
        petExists: .constant(false),
    )
        .padding(.all)
        .modelContainer(DataController.previewContainer)
        .background(.ultraThinMaterial)
        .padding()
}

#endif
