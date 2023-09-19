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

    var feedsArray: [Feed] {
        let feeds = self.feeds ?? []
        return feeds.sorted { first, second in
            first.wrappedFeedDate < second.wrappedFeedDate
        }
    }

    var vaccinesArray: [Vaccine] {
        let vaccines = self.vaccines ?? []
        return vaccines.sorted { first, second in
            first.date < second.date
        }
    }
}
