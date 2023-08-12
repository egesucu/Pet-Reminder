//
//  PetNameTextField.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetNameTextField: View {

    @Binding var name: String

    @FocusState var isFocused
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    var body: some View {
        VStack {
            Text("start_name_label")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            ZStack {
                Rectangle()
                    .fill(
                        isFocused ? tintColor
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
            }
            .cornerRadius(5)
            .frame(height: 50)
        }

    }
}

#Preview {
    PetNameTextField(name: .constant(Strings.viski))
        .padding(.all)
}
