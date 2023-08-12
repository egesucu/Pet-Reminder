//
//  EventTimeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct EventTimeView: View {

    @Binding var dateString: String
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 100).fill(tintColor)
            Text(dateString)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(tintColor.isDarkColor ? .white : .black)
        }
    }
}

#Preview {
    EventTimeView(dateString: .constant(Strings.demo))
}
