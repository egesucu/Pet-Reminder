//
//  PreviousFeedsSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SwiftData

struct PreviousFeedsSection: View {
    var feeds: [Feed]?

    var previousFeeds: [Feed] {
        feeds?
            .filter { !Calendar.current.isDateInToday(
                $0.feedDate ?? .now
            )
            } ?? []
    }

    var body: some View {
        if previousFeeds.isEmpty {
            Text("no_feed_content")
        } else {
            ForEach(previousFeeds, id: \Feed.id) { feed in
                if let morning = feed.morningFedStamp {
                    HStack {
                        Row(
                            imageName: "sun.max.fill",
                            content: morning.formatted(
                                date: .abbreviated,
                                time: .shortened
                            ),
                            type: .morning
                        )
                        Spacer()
                    }
                }
                if let evening = feed.eveningFedStamp {
                    HStack {
                        Spacer()
                        Row(
                            imageName: "moon.circle.fill",
                            content: evening.formatted(
                                date: .abbreviated,
                                time: .shortened
                            ),
                            type: .evening
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable var feeds: [Feed] = Feed.previews

    PreviousFeedsSection(feeds: feeds)
        .modelContainer(DataController.previewContainer)
}
