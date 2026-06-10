//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct FeedHistory: View {

    var feeds: [Feed]?

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            ScrollView {
                Text(.today)
                    .bold()
                    .font(.title2)
                    .padding(.leading, .spacing8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                CurrentFeedSection(feeds: feeds)
                Text(.previousTitle)
                    .bold()
                    .font(.title2)
                    .padding(.top, .spacing8)
                    .padding(.leading, .spacing8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                PreviousFeedsSection(feeds: feeds)
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background(.regularMaterial)
        .navigationTitle(Text(.feedHistoryTitle))
    }
}

#if DEBUG
#Preview {
    var feeds: [Feed] = Feed.previews
    let todayFeed = Feed(
        eveningFed: true,
        eveningFedStamp: .eightPM,
        feedDate: .now,
        morningFed: true,
        morningFedStamp: .eightAM
    )
    feeds.append(todayFeed)

    return NavigationStack {
        FeedHistory(feeds: feeds)
    }
}
#endif
