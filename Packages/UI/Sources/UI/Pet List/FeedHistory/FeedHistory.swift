//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

struct FeedHistory: View {

    var feeds: [Feed]?

    @Environment(\.dismiss) var dismiss

    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    public var body: some View {

        NavigationStack {
            List {
                CurrentFeedSection(feeds: feeds)
                PreviousFeedsSection(feeds: feeds)
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.topBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .tint(tintColor.color)
                    }
                }
            }
            .navigationTitle(Text("feed_history_title", bundle: .module))
        }
    }
}

#Preview {
    NavigationStack {
        FeedHistory(feeds: [.init()])
            .modelContainer(DataController.previewContainer)
    }
}
