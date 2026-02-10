//
//  PetBirthdayView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PetBirthdayView: View {

    @Binding var addPet: AddPet

    var body: some View {
        VStack(alignment: .center) {
            Text(.birthdayAskLabel)
                .font(.title2)
                .foregroundStyle(Color.label)
                .bold()
            DatePicker(
                selection: $addPet.birthday,
                displayedComponents: .date
            ) {
                Text(.birthdayTitle)
            }
            .labelsHidden()
            .tint(.green)
        }
        .padding(.all)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var addPet: AddPet = .init()
    PetBirthdayView(addPet: $addPet)
}
#endif
