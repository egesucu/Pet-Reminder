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
            ActionButton(
                action: onCancel,
                content: .cancel,
                systemImage: SFSymbols.xmarkSealFill,
                isEnabled: true,
                tint: .red
            )
            .padding(.trailing, 50)
            ActionButton(
                action: onSave,
                content: .save,
                systemImage: SFSymbols.pawprintCircleFill,
                isEnabled: name.isEmpty,
                tint: .green
            )
        }
        .padding(.all)
    }
}

struct AddPetActionsView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetActionsView(name: .constant(Strings.viski)) {

        } onCancel: {

        }

    }
}
