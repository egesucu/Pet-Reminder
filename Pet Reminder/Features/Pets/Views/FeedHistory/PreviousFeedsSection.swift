//
//  PreviousFeedsSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PreviousFeedsSection: View {
    var feeds: [Feed]?

    var body: some View {
        Section {
            if ((feeds?
                .filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty) != nil) {
                Text("no_feed_content")
            } else {
                ForEach(
                    feeds?
                        .filter(
                            { !Calendar.current.isDateInToday(
                                $0.feedDate ?? .now
                            )
                            }) ?? [],
                    id: \.self
                ) { feed in
                    if let morning = feed.morningFedStamp {
                        Row(
                            imageName: "sun.max.fill",
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
            Text("previous_title")
        }
    }
}

#Preview {
    @Previewable var feeds: [Feed] = Feed.previews
    
    PreviousFeedsSection(feeds: feeds)
        .modelContainer(DataController.previewContainer)
}
