//
//  CurrentFeedSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SharedModels

struct CurrentFeedSection: View {

    public var feeds: [Feed]?

    public var filteredFeeds: [Feed] {
        feeds?
            .filter {
                if let date =  $0.feedDate {
                    return Calendar.current.isDateInToday(date)
                }
                return false
            } ?? []
    }

    public var body: some View {
        Section {
            if filteredFeeds.isEmpty {
                Text("no_feed_today_content", bundle: .module)
            } else {
                ForEach(filteredFeeds, id: \.self) { feed in
                    if let morning = feed.morningFedStamp {
                        Row(
                            imageName: "sun.max.circle.fill",
                            title: String(
                                localized: "feed_content"
                            ),
                            content: morning.formatted(
                                date: .abbreviated,
                                time: .shortened
                            ),
                            type: .morning
                        )
                    }
                    if let evening = feed.eveningFedStamp {
                        Row(
                            imageName: "moon.circle.fill",
                            title: String(
                                localized: "feed_content"
                            ),
                            content: evening.formatted(
                                date: .abbreviated,
                                time: .shortened
                            ),
                            type: .evening
                        )
                    }
                }
            }
        } header: {
            Text("today", bundle: .module)
        }
    }
}

#Preview {
    let feeds: [Feed] = Pet.preview.feeds ?? []
    CurrentFeedSection(feeds: feeds)
        .modelContainer(DataController.previewContainer)
}
