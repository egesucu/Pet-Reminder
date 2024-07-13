//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

public extension Feed {
    var wrappedFeedDate: Date {
        self.feedDate ?? .now
    }

    var wrappedMorningFedStamp: Date {
        self.morningFedStamp ?? .now
    }

    var wrappedEveningFedStamp: Date {
        self.eveningFedStamp ?? .now
    }

    static var preview: Feed {
        Feed(
            eveningFed: true,
            eveningFedStamp: .eightPM,
            feedDate: .eightPM,
            morningFed: true,
            morningFedStamp: .eightAM
        )
    }

    static var previews: [Feed] {
        var feeds: [Feed] = []
        [0...4].forEach { _ in
            let date = Date.randomDate()
            let feed = Feed(
                eveningFed: true,
                eveningFedStamp: date,
                feedDate: date,
                morningFed: true,
                morningFedStamp: date
            )
            feeds.append(feed)
        }
        return feeds
    }

}
