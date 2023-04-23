//
//  PetNameTextField.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct PetNameTextField: View {
    
    @Binding var name: String
    
    var body: some View {
        VStack {
            Text("start_name_label")
                .font(.title2)
                .bold()
            TextField("Doggo", text: $name)
                .font(.title)
                .padding()
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .background(Color.black.opacity(0.1))
                .cornerRadius(5)
                .shadow(radius: 8)
        }
    }
}

struct PetNameTextField_Previews: PreviewProvider {
    static var previews: some View {
        PetNameTextField(name: .constant("Viski"))
    }
}
