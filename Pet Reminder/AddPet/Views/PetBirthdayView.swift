//
//  PetBirthdayView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI


struct PetBirthdayView: View {

    @Binding var birthday: Date
    

    var body: some View {
        VStack(alignment: .leading) {
            Text("birthday_title")
                .font(.title2)
                .foregroundStyle(.white)
                .bold()
                .padding(.trailing, 20)
            DatePicker(
                selection: $birthday,
                displayedComponents: .date) {
                    Text("birthday_title")
                        .foregroundStyle(.white)
                }
                .labelsHidden()
                .tint(.white)
        }
        .padding(.all)
    }
}

#Preview {
    PetBirthdayView(birthday: .constant(.now))
        .background(Color.accent, ignoresSafeAreaEdges: .all)
}
