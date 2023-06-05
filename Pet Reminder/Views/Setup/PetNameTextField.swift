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
    
    var body: some View {
        VStack {
            Text(Strings.startNameLabel)
                .font(.title2)
                .bold()
            TextField(Strings.doggo, text: $name)
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
        PetNameTextField(name: .constant(Strings.viski))
    }
}