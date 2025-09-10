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

    @Binding var birthday: Date

    var body: some View {
        VStack(alignment: .center) {
            Text(.birthdayTitle)
                .font(.title2)
                .foregroundStyle(Color.label)
                .bold()
            DatePicker(
                selection: $birthday,
                displayedComponents: .date) {
                    Text(.birthdayTitle)
                        .foregroundStyle(Color.label)
                }
                .labelsHidden()
                .tint(.white)
        }
        .padding(.all)
    }
}

#if DEBUG

#Preview {
    PetBirthdayView(birthday: .constant(.now))
}

#endif
