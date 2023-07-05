//
//  AddPetActionsView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct AddPetActionsView: View {

    @Binding var name: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        HStack {
            Button(action: onCancel) {
                Label("cancel", systemImage: SFSymbols.xmarkSealFill)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.trailing, 50)
            Button(action: onSave) {
                Label("save", systemImage: SFSymbols.pawprintCircleFill)
            }
            .buttonStyle(.bordered)
            .tint(.green)
            .disabled(name.isEmpty)
        }
        .padding(.all)
    }
}

struct AddPetActionsView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetActionsView(name: .constant(Strings.viski)) {
            print("Saved")
        } onCancel: {
            print("Cancelled")
        }

    }
}
