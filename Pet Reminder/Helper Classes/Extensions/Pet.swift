//
//  Pet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation

extension Pet {
    var selection: FeedTimeSelection {
        get {
            return FeedTimeSelection(rawValue: self.choice) ?? .both
        }
        set {
            choice = newValue.rawValue
        }
    }

    var wrappedName: String {
        self.name ?? ""
    }

    var wrappedBirthday: Date {
        self.birthday ?? .now
    }

    var feedsArray: [Feed] {
        let feedSet = self.feeds as? Set<Feed> ?? []
        return feedSet.sorted { first, second in
            first.wrappedFeedDate < second.wrappedFeedDate
        }
    }

    var vaccinesArray: [Vaccine] {
        let vaccineSet = self.vaccines as? Set<Vaccine> ?? []
        return vaccineSet.sorted { first, second in
            first.wrappedDate < second.wrappedDate
        }
    }
}
