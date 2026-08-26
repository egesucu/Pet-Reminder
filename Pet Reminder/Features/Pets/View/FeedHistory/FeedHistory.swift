//
//  FeedHistory.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.10.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct FeedHistory: View {
    let feeds: [Feed]?
    let feedSelection: FeedSelection

    init(feeds: [Feed]?, feedSelection: FeedSelection = .both) {
        self.feeds = feeds
        self.feedSelection = feedSelection
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .spacing24) {
                FeedInsightsSection(records: records, feedSelection: feedSelection)
                CurrentFeedSection(record: todayRecord)
                PreviousFeedsSection(records: previousRecords)
            }
            .padding(.horizontal, .spacing20)
            .padding(.top, .spacing16)
            .padding(.bottom, .spacing32)
        }
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(Text(.feedHistoryTitle))
    }

    private var records: [FeedDayRecord] {
        FeedDayRecord.makeRecords(from: feeds ?? [])
    }

    private var todayRecord: FeedDayRecord? {
        records.first { Calendar.current.isDateInToday($0.date) }
    }

    private var previousRecords: [FeedDayRecord] {
        records.filter { !Calendar.current.isDateInToday($0.date) }
    }
}

struct FeedDayRecord: Identifiable {
    let date: Date
    let morningTime: Date?
    let eveningTime: Date?

    var id: Date { date }

    var completedCount: Int {
        [morningTime, eveningTime].compactMap { $0 }.count
    }

    func completedCount(for selection: FeedSelection) -> Int {
        switch selection {
        case .morning:
            morningTime == nil ? 0 : 1
        case .evening:
            eveningTime == nil ? 0 : 1
        case .both:
            completedCount
        }
    }

    static func makeRecords(from feeds: [Feed]) -> [FeedDayRecord] {
        let calendar = Calendar.current
        let groupedFeeds = Dictionary(grouping: feeds) { feed in
            calendar.startOfDay(
                for: feed.feedDate ?? feed.morningFedStamp ?? feed.eveningFedStamp ?? .distantPast
            )
        }

        return groupedFeeds
            .filter { $0.key != calendar.startOfDay(for: .distantPast) }
            .map { date, feeds in
                FeedDayRecord(
                    date: date,
                    morningTime: feeds.compactMap(\.morningFedStamp).max(),
                    eveningTime: feeds.compactMap(\.eveningFedStamp).max()
                )
            }
            .filter { $0.completedCount > 0 }
            .sorted { $0.date > $1.date }
    }
}

#if DEBUG
#Preview {
    var feeds: [Feed] = Feed.previews
    feeds.append(
        Feed(
            eveningFed: true,
            eveningFedStamp: .eightPM,
            feedDate: .now,
            morningFed: true,
            morningFedStamp: .eightAM
        )
    )

    return NavigationStack {
        FeedHistory(feeds: feeds)
    }
}

#Preview("More Data") {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let feeds = (0...50).compactMap { daysAgo -> Feed? in
        guard let feedDate = calendar.date(byAdding: .day, value: -daysAgo, to: today),
              let morningTime = calendar.date(bySettingHour: 8, minute: daysAgo % 60, second: 0, of: feedDate) else {
            return nil
        }

        let hasEveningFeed = !daysAgo.isMultiple(of: 4)
        let eveningTime = hasEveningFeed
            ? calendar.date(bySettingHour: 20, minute: daysAgo % 60, second: 0, of: feedDate)
            : nil

        return Feed(
            eveningFed: hasEveningFeed,
            eveningFedStamp: eveningTime,
            feedDate: feedDate,
            morningFed: true,
            morningFedStamp: morningTime
        )
    }

    NavigationStack {
        FeedHistory(feeds: feeds)
    }
}

#Preview("Empty") {
    NavigationStack {
        FeedHistory(feeds: [])
    }
}
#endif
