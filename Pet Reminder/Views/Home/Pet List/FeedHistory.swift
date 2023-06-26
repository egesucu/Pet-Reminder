//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct FeedHistory: View {

    var feeds: [Feed]
    var context: NSManagedObjectContext
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
            .navigationTitle(Text(Strings.feedHistoryTitle))
        }
    }
}

struct CurrentFeedSection: View {

    var feeds: [Feed]

    var body: some View {
        Section {
            if feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty {
                Text(Strings.noFeedTodayContent)
            } else {
                ForEach(feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now) }), id: \.self) { feed in
                    if let morning = feed.morningFedStamp {
                        Row(imageName: "sun.max.circle.fill", title: Strings.feedContent, content: morning.formatted(date: .abbreviated, time: .shortened), type: .morning)
                    }
                    if let evening = feed.eveningFedStamp {
                        Row(imageName: "moon.circle.fill", title: Strings.feedContent, content: evening.formatted(date: .abbreviated, time: .shortened), type: .evening)
                    }
                }
            }
        } header: {
            Text(Strings.today)
        }
    }
}

struct PreviousFeedsSection: View {
    var feeds: [Feed]

    var body: some View {
        Section {
            if feeds.filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty {
                Text(Strings.noFeedContent)
            } else {
                ForEach(feeds.filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }), id: \.self) { feed in
                    if let morning = feed.morningFedStamp {
                        Row(imageName: "sun.max.fill", title: Strings.feedContent, content: morning.formatted(date: .abbreviated, time: .shortened), type: .morning)
                    }
                    if let evening = feed.eveningFedStamp {
                        Row(imageName: "moon.circle.fill", title: Strings.feedContent, content: evening.formatted(date: .abbreviated, time: .shortened), type: .evening)
                    }
                }
            }
        } header: {
            Text(Strings.previousTitle)
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

struct FeedHistory_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        let pet = Pet(context: previewContext)
        for i in 0..<5 {
            let feed = Feed(context: previewContext)
            let components = DateComponents(year: Int.random(in: 2018...2023), month: Int.random(in: 0...12), day: Int.random(in: 0...30), hour: Int.random(in: 0...23), minute: Int.random(in: 0...59), second: Int.random(in: 0...59))
            if i % 2 == 0 {
                feed.morningFedStamp = Calendar.current.date(from: components)
                feed.morningFed = true
            } else {
                feed.eveningFedStamp = Calendar.current.date(from: components)
                feed.eveningFed = true
            }
            feed.feedDate = Calendar.current.date(from: components)
            pet.addToFeeds(feed)
        }
        return NavigationView {
            FeedHistory(feeds: (pet.feeds?.allObjects as? [Feed] ?? []).sorted(by: { $0.feedDate ?? .now > $1.feedDate ?? .now }), context: previewContext)
        }
    }
}
