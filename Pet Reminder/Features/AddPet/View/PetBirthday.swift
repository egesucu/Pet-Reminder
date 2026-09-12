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
        VStack(alignment: .leading, spacing: .spacing20) {
            Text(.birthdayAskLabel)
                .font(.headline)
                .foregroundStyle(Color.label)
            
            DatePicker(
                String(localized: .birthdayTitle),
                selection: $model.birthday,
                displayedComponents: .date
            )
            .labelsHidden()
            .tint(.green)
            
            VStack(alignment: .center, spacing: .spacing20) {
                Text(.birthdayInformation)
                    .font(.caption2)
                    .foregroundStyle(Color.label)
            }
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var model: AddPet.Model = .init()
    
    PetBirthday(model: $model)
        .padding(.horizontal)
}
#endif
