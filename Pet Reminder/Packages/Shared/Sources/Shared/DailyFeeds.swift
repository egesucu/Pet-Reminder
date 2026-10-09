import Foundation
import SwiftData

/// Uses the same day's records for display and mutations, including synced duplicates.
@MainActor
public enum DailyFeeds {
    public static func records(for pet: Pet, at date: Date, calendar: Calendar = .current) -> [Feed] {
        (pet.feeds ?? []).filter {
            guard let feedDate = $0.feedDate else { return false }
            return calendar.isDate(feedDate, inSameDayAs: date)
        }
    }

    public static func isFed(_ type: FeedSelection, pet: Pet, at date: Date, calendar: Calendar = .current) -> Bool {
        let feeds = records(for: pet, at: date, calendar: calendar)
        switch type {
        case .morning: return feeds.contains { $0.morningFed }
        case .evening: return feeds.contains { $0.eveningFed }
        case .both:
            return feeds.contains { $0.morningFed } && feeds.contains { $0.eveningFed }
        }
    }

    public static func toggle(_ type: FeedSelection, pet: Pet, at date: Date, context: ModelContext) throws {
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

    /// A repeatable command: never toggles a completed meal or replaces its timestamp.
    public static func markFed(
        _ type: FeedSelection,
        pet: Pet,
        at date: Date,
        calendar: Calendar = .current,
        context: ModelContext,
        save: (ModelContext) throws -> Void = { try $0.save() }
    ) throws {
        guard type != .both, pet.feedSelection == .both || pet.feedSelection == type else {
            throw PetCareError.unsupportedMeal
        }
        var feeds = records(for: pet, at: date, calendar: calendar)
        if feeds.isEmpty {
            let feed = Feed(feedDate: date)
            pet.addFeed(feed)
            feeds = [feed]
        }
        let alreadyFed = isFed(type, pet: pet, at: date, calendar: calendar)
        let existingStamp = feeds.filter {
            type == .morning ? $0.morningFed : $0.eveningFed
        }.compactMap {
            type == .morning ? $0.morningFedStamp : $0.eveningFedStamp
        }.max()
        // A legacy completed record without a timestamp must not be stamped as a new meal.
        let stamp = alreadyFed ? existingStamp : date
        for feed in feeds {
            if type == .morning {
                if !feed.morningFed {
                    feed.morningFed = true
                    feed.morningFedStamp = stamp
                }
            } else if !feed.eveningFed {
                feed.eveningFed = true
                feed.eveningFedStamp = stamp
            }
        }
        do {
            try save(context)
        } catch {
            context.rollback()
            throw PetCareError.saveFailed
        }
    }

}
