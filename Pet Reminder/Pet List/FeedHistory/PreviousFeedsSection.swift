//
//  PreviousFeedsSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct PreviousFeedsSection: View {
    var feeds: [Feed]

    var body: some View {
        Section {
            if feeds.filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty {
                Text("no_feed_content")
            } else {
                ForEach(feeds.filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }), id: \.self) { feed in
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
    let preview = PersistenceController.preview.container.viewContext
    let feeds = Pet(context: preview).feeds?.allObjects as? [Feed] ?? []
    return PreviousFeedsSection(feeds: feeds)
        .environment(\.managedObjectContext, preview)
}
