//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct FeedHistory: View {
    
    var feeds: [Feed]
    var context: NSManagedObjectContext
    
    var body: some View {
        
        List{
            Section {
                if feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty{
                    Text("No Feed today.")
                } else {
                    ForEach(feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now) }), id: \.self) { feed in
                        if let morning = feed.morningFedStamp{
                            Row(title: "Morning Feed Time", content: morning.formatted(date: .abbreviated, time: .shortened))
                        }
                        if let evening = feed.eveningFedStamp{
                            Row(title: "Evening Feed Time", content: evening.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                }
            } header: {
                Text("Today")
            }
            
            Section {
                if feeds.filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }).isEmpty{
                    Text("No Feed today.")
                } else {
                    ForEach(feeds.filter({ !Calendar.current.isDateInToday($0.feedDate ?? .now) }), id: \.self) { feed in
                        if let morning = feed.morningFedStamp{
                            Row(title: "Morning Feed Time", content: morning.formatted(date: .abbreviated, time: .shortened))
                        }
                        if let evening = feed.eveningFedStamp{
                            Row(title: "Evening Feed Time", content: evening.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                }
            } header: {
                Text("Previous")
            }

        }
        
    }
}

struct Row: View {
    var title: String
    var content: String
    
    var body: some View {
        HStack{
            Text(title).bold()
            Text(content)
        }
    }
}

struct FeedHistory_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        let pet = Pet(context: previewContext)
        for i in 0..<5{
            let feed = Feed(context: previewContext)
            let components = DateComponents(year: Int.random(in: 2018...2023), month: Int.random(in: 0...12), day: Int.random(in: 0...30), hour: Int.random(in: 0...23), minute: Int.random(in: 0...59), second: Int.random(in: 0...59))
            if i % 2 == 0{
                feed.morningFedStamp = Calendar.current.date(from: components)
                feed.morningFed = true
            } else {
                feed.eveningFedStamp = Calendar.current.date(from: components)
                feed.eveningFed = true
            }
            feed.feedDate = Calendar.current.date(from: components)
            pet.addToFeeds(feed)
        }
        return FeedHistory(feeds: (pet.feeds?.allObjects as? [Feed] ?? []).sorted(by: { $0.feedDate ?? .now > $1.feedDate ?? .now }), context: previewContext)
    }
}
