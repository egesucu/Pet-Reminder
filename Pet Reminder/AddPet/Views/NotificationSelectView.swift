//
//  NotificationSelectView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI


struct NotificationSelectView: View {

    @Binding var dayType: FeedSelection

    var body: some View {
        VStack {
            Text("feed_time_title")
                .font(.title2).bold()
                .foregroundStyle(.white)
                .padding(.vertical)
                .animation(.easeOut(duration: 0.8), value: dayType)
            Picker(
                selection: $dayType,
                label: Text("feed_time_title")
            ) {
                Text("feed_selection_both")
                    .tag(FeedSelection.both)
                    .foregroundStyle(.white)
                Text("feed_selection_morning")
                    .tag(FeedSelection.morning)
                    .foregroundStyle(.white)
                Text("feed_selection_evening")
                    .tag(FeedSelection.evening)
                    .foregroundStyle(.white)
            }
            .pickerStyle(.segmented)
            .animation(.easeOut(duration: 0.8), value: dayType)
        }
    }
}

#Preview {
    @Previewable @State var dayType: FeedSelection = .both
    NotificationSelectView(dayType: $dayType)
        .background(
            Color.accent,
            ignoresSafeAreaEdges: .all
        )
}
