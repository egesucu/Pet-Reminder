//
//  EventTime.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct EventTime: View {

    @Binding var dateString: String

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: .pill).fill(.accent)
            Text(dateString)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(Color.accent.isDarkColor ? .white : .black)
        }
    }
}

#if DEBUG
#Preview {
    EventTime(dateString: .constant(Strings.demo))
}
#endif
