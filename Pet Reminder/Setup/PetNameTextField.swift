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
    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accent)

    var body: some View {
        VStack {
            Text("start_name_label")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            ZStack {
                Rectangle()
                    .fill(
                        isFocused ? tintColor.color
                            .opacity(0.1) :
                            Color
                                .black
                                .opacity(0.1)

                    )
                    .animation(.easeInOut, value: isFocused)
                    .shadow(radius: 8)
                TextField(
                    Strings.doggo,
                    text: $name
                )
                .focused($isFocused)
                .font(.title)
                .padding()
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .onSubmit(controlName)
            }
            .clipShape(.rect(cornerRadius: 5))
            .frame(height: 50)
        }
        .alert(isPresented: $showAlert, error: PetError.name) {
            Button(action: {

            }, label: {
                Text("OK")
            })
        }

    }

    func controlName() {
        let pet = pets.filter({ $0.name == name })
        if pet.isNotEmpty {
            name = ""
            showAlert.toggle()
        } else {
            nameIsFilledCorrectly = true
        }
    }
}

#Preview {
    PetNameTextField(name: .constant(Strings.viski), nameIsFilledCorrectly: .constant(false))
        .padding(.all)
        .modelContainer(PreviewSampleData.container)
}
