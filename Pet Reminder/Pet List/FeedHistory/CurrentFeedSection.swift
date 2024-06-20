//
//  CurrentFeedSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct CurrentFeedSection: View {

    var feeds: [Feed]?

    var filteredFeeds: [Feed] {
        feeds?
            .filter {
                if let date =  $0.feedDate {
                    return Calendar.current.isDateInToday(date)
                }
                return false
            } ?? []
    }

    var body: some View {
        Section {
            if filteredFeeds.isEmpty {
                Text("no_feed_today_content")
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
            Text("today")
        }
    }
}

#Preview {
    let feeds: [Feed] = Pet.preview.feeds ?? []
    return CurrentFeedSection(feeds: feeds)
        .modelContainer(PreviewSampleData.container)
}
