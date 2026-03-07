//
//  EventTitleView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct EventTitleView: View {

    var eventTitle: String

    var body: some View {
        Text(eventTitle)
            .font(.headline)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
#Preview {
    EventTitleView(eventTitle: "Event")
}
#endif
