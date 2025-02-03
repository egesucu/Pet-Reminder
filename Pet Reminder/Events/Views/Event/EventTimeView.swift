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
    

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 100).fill(.accent)
            Text(dateString)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(Color.accent.isDarkColor ? .white : .black)
        }
    }
}

#Preview {
    EventTimeView(dateString: .constant(Strings.demo))
}
