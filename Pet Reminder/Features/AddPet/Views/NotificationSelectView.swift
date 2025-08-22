//
//  NotificationSelectView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct NotificationSelectView: View {

    @Binding var feedSelection: FeedSelection

    var body: some View {
        VStack(spacing: 10) {
            Text(.feedTimeTitle)
                .font(.title3).bold()
                .foregroundStyle(Color.label)
                .padding(.vertical)
                .animation(.easeOut(duration: 0.8), value: feedSelection)
            Picker(
                selection: $feedSelection,
                label: Text(.feedTimeTitle)
            ) {
                Text(.feedSelectionBoth)
                    .tag(FeedSelection.both)
                    .foregroundStyle(Color.label)
                Text(.feedSelectionMorning)
                    .tag(FeedSelection.morning)
                    .foregroundStyle(Color.label)
                Text(.feedSelectionEvening)
                    .tag(FeedSelection.evening)
                    .foregroundStyle(Color.label)
            }
            .pickerStyle(.menu)
            .tint(.accent)
            .animation(.easeOut(duration: 0.8), value: feedSelection)
        }
    }
}

#Preview {
    @Previewable @State var feedSelection: FeedSelection = .both
    NotificationSelectView(feedSelection: $feedSelection)
        .background(.ultraThinMaterial)
}
