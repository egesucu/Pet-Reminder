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
    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        HStack {
            Spacer()
            Text("birthday_title")
                .font(.title2)
                .bold()
                .padding(.trailing, 20)
            DatePicker("birthday_title", selection: $birthday, displayedComponents: .date)
                .labelsHidden()
                .tint(tintColor)
            Spacer()
        }
        .padding(.all)
    }
}

struct PetBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        PetBirthdayView(birthday: .constant(.now))
    }
}
