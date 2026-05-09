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

struct FeedHistory: View {

    @Environment(\.dismiss) var dismiss
    var feeds: [Feed]?

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel, action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
                }
            }
            .scrollContentBackground(.hidden)
            .background(.regularMaterial)
            .navigationTitle(Text(.feedHistoryTitle))
        }
        .presentationBackground(.clear)
        .presentationCornerRadius(.radius24)
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

    return FeedHistory(feeds: feeds)
}
#endif
