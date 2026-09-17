import Foundation
import Shared
import SwiftData

/// Uses the same day's records for display and mutations, including synced duplicates.
@MainActor
enum DailyFeeds {
    static func records(for pet: Pet, at date: Date, calendar: Calendar = .current) -> [Feed] {
        (pet.feeds ?? []).filter {
            guard let feedDate = $0.feedDate else { return false }
            return calendar.isDate(feedDate, inSameDayAs: date)
        }
    }

    static func isFed(_ type: FeedSelection, pet: Pet, at date: Date) -> Bool {
        let feeds = records(for: pet, at: date)
        switch type {
        case .morning: return feeds.contains { $0.morningFed }
        case .evening: return feeds.contains { $0.eveningFed }
        case .both:
            return feeds.contains { $0.morningFed } && feeds.contains { $0.eveningFed }
        }
    }

    static func toggle(_ type: FeedSelection, pet: Pet, at date: Date, context: ModelContext) throws {
        let newValue = !isFed(type, pet: pet, at: date)
        var feeds = records(for: pet, at: date)
        if feeds.isEmpty {
            let feed = Feed(feedDate: date)
            pet.addFeed(feed)
            feeds = [feed]
        }
        for feed in feeds {
            if type == .morning || type == .both {
                feed.morningFed = newValue
                feed.morningFedStamp = newValue ? date : nil
            }
            if type == .evening || type == .both {
                feed.eveningFed = newValue
                feed.eveningFedStamp = newValue ? date : nil
            }
        }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
