//
//  PetNameTextField.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData


struct PetNameTextField: View {
    @Query(sort: \Pet.name) var pets: [Pet]

    @Binding var name: String
    @State private var showAlert = false
    @Binding var nameIsFilledCorrectly: Bool

    @FocusState var isFocused
    

    var body: some View {
        VStack(alignment: .leading) {
            Text("start_name_label")
                .foregroundStyle(Color.white)
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            TextField(
                Strings.doggo,
                text: $name
            )
            .focused($isFocused)
            .foregroundStyle(Color.white)
            .font(.title)
            .padding()
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .multilineTextAlignment(.center)
            .onChange(of: name) {
                adjust(name: name)
            }
            .background(
                Rectangle()
                    .fill(
                        isFocused ? .black
                            .opacity(0.2) :
                            Color
                                .white
                                .opacity(0.4)

                    )
                    .animation(.easeInOut, value: isFocused)
                    .shadow(radius: 8)
            )
        }
    }
    
    private func adjust(name: String) {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty {
            nameIsFilledCorrectly = true
        } else {
            nameIsFilledCorrectly = false
        }
    }
}

#Preview("Filled Case") {
    PetNameTextField(name: .constant(Strings.viski), nameIsFilledCorrectly: .constant(false))
        .padding(.all)
        .modelContainer(DataController.previewContainer)
        .background(
            Color.accent
                .ignoresSafeArea()
        )
}

#Preview("Empty Case") {
    PetNameTextField(name: .constant(""), nameIsFilledCorrectly: .constant(false))
        .padding(.all)
        .modelContainer(DataController.previewContainer)
        .background(
            Color.accent
                .ignoresSafeArea()
        )
}
