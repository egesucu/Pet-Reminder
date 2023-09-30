//
//  NotificationSelectView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct NotificationSelectView: View {

    @Binding var dayType: FeedTimeSelection

    var body: some View {
        VStack {
            Text("feed_time_title")
                .font(.title2).bold()
                .padding(.vertical)
            Picker(
                selection: $dayType,
                label: Text("feed_time_title")
            ) {
                Text("feed_selection_both")
                    .tag(FeedTimeSelection.both)
                Text("feed_selection_morning")
                    .tag(FeedTimeSelection.morning)
                Text("feed_selection_evening")
                    .tag(FeedTimeSelection.evening)
            }
            .pickerStyle(.segmented)
            .animation(.easeOut(duration: 0.8), value: dayType)
        }
    }
}

#Preview {
    NotificationSelectView(dayType: .constant(.both))
}
