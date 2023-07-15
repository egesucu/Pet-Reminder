//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct FeedHistory: View {

    var feeds: [Feed]

    @Environment(\.dismiss) var dismiss

    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {

        NavigationView {
            List {
                CurrentFeedSection(feeds: feeds)
                PreviousFeedsSection(feeds: feeds)
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark.circle.fill")
                            .tint(tintColor)
                    }
                }
            }
            .navigationTitle(Text("feed_history_title"))
        }
    }
}

struct CurrentFeedSection: View {

    var feeds: [Feed]

    var body: some View {
        Section {
            if feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty {
                Text("no_feed_today_content")
            } else {
                ForEach(feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now) }), id: \.self) { feed in
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

struct Row: View {
    var imageName: String
    var title: String
    var content: String
    var type: NotificationType

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .symbolRenderingMode(.hierarchical)
                .font(.title)
                .foregroundColor(type == .morning ? .yellow  : .blue)
            Text(content)
        }
    }
}

#Preview {
    let viewContext = PersistenceController.preview.container.viewContext
    return NavigationView {
        FeedHistory(feeds: [Feed(context: viewContext)])
    }
}
