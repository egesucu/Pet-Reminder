//
//  PetBirthday.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PetBirthday: View {

    @Binding var model: AddPet.Model

    var body: some View {
        VStack(alignment: .center) {
            Text(.birthdayAskLabel)
                .font(.title2)
                .foregroundStyle(Color.label)
                .bold()
            DatePicker(
                selection: $model.birthday,
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
    @Previewable @State var model: AddPet.Model = .init()
    PetBirthday(model: $model)
}
#endif
