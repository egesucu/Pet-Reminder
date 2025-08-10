//
//  CurrentFeedSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import Shared

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
        if filteredFeeds.isEmpty {
            Text("no_feed_today_content")
        } else {
            ForEach(filteredFeeds, id: \.id) { feed in
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
    let today = Date.now
    let feed = Feed(
        eveningFed: true,
        eveningFedStamp: today,
        feedDate: today,
        morningFed: true,
        morningFedStamp: today
    )
    CurrentFeedSection(feeds: [feed])
        .modelContainer(DataController.previewContainer)
}
