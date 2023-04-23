//
//  AddPetActionsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct AddPetActionsView: View {
    
    @Binding var name: String
    var onSave: () -> ()
    var onCancel: () -> ()
    
    var body: some View {
        HStack {
            ActionButton(action: onCancel, content: "cancel", systemImage: "xmark.seal.fill", isEnabled: true, tint: .red)
            .padding(.trailing, 50)
            ActionButton(action: onSave, content: "save", systemImage: "pawprint.circle.fill", isEnabled: name.isEmpty, tint: .green)
        }
        .padding(.all)
    }
}



struct AddPetActionsView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetActionsView(name: .constant("Viski")) {
            
        } onCancel: {
            
        }

    }
}
