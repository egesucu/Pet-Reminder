//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SwiftData
import SFSafeSymbols

struct FeedHistory: View {

    var feeds: [Feed]?

    @Environment(\.dismiss) var dismiss

    var body: some View {

        NavigationStack {
            List {
                CurrentFeedSection(feeds: feeds)
                PreviousFeedsSection(feeds: feeds)
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.topBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemSymbol: .xmarkCircle)
                            .font(.title)
                            .tint(.red)
                    }
                }
            }
            .navigationTitle(Text("feed_history_title"))
            .navigationBarTitleTextColor(.accent)
        }
    }
}

#Preview {
    NavigationStack {
        FeedHistory(feeds: [.init()])
            .modelContainer(DataController.previewContainer)
    }
}
