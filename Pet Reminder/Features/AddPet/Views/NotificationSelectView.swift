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
        VStack(spacing: 20) {
            Text(.feedTimeTitle)
                .font(.title3)
                .bold()
                .foregroundStyle(Color.label)
                .animation(.easeOut(duration: 0.8), value: feedSelection)
            Picker(
                selection: $feedSelection,
                label: Text(.feedTimeTitle)
            ) {
                ForEach(FeedSelection.allCases, id: \.description) {
                    Text($0.localized)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .tint(.green)
            .animation(.easeOut(duration: 0.8), value: feedSelection)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var feedSelection: FeedSelection = .both
    NotificationSelectView(feedSelection: $feedSelection)
        .padding()
}
#endif
