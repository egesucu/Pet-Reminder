//
//  EventTitleView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

public struct EventTitleView: View {

    @Binding var eventTitle: String

    public var body: some View {
        Text(eventTitle)
            .font(.headline)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    EventTitleView(eventTitle: .constant("Event"))
}
