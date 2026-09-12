import Foundation
import Testing
import Shared
@testable import Pet_Reminder

@MainActor
struct `Feed Day Record Tests` {

    @Test
    func `Records group feeds by day and keep latest stamps`() throws {
        let calendar = Calendar.current
        let day = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 20)))
        let earlyMorning = try #require(calendar.date(bySettingHour: 7, minute: 30, second: 0, of: day))
        let lateMorning = try #require(calendar.date(bySettingHour: 8, minute: 15, second: 0, of: day))
        let evening = try #require(calendar.date(bySettingHour: 20, minute: 0, second: 0, of: day))

        let records = FeedDayRecord.makeRecords(from: [
            Feed(feedDate: day, morningFed: true, morningFedStamp: earlyMorning),
            Feed(eveningFed: true, eveningFedStamp: evening, feedDate: day),
            Feed(feedDate: day, morningFed: true, morningFedStamp: lateMorning)
        ])

        #expect(records.count == 1)
        #expect(records.first?.morningTime == lateMorning)
        #expect(records.first?.eveningTime == evening)
        #expect(records.first?.completedCount == 2)
    }

    @Test
    func `Completion respects the configured feeding schedule`() {
        let record = FeedDayRecord(
            date: .now,
            morningTime: .now,
            eveningTime: nil
        )

        #expect(record.completedCount(for: .morning) == 1)
        #expect(record.completedCount(for: .evening) == 0)
        #expect(record.completedCount(for: .both) == 1)
    }

    @Test
    func `Records without any completion are discarded`() {
        let records = FeedDayRecord.makeRecords(from: [Feed(feedDate: .now)])

        #expect(records.isEmpty)
    }
}
