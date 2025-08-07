//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
//

import Foundation
import SwiftData
import Playgrounds

@Model
public class Feed {
    public var eveningFed: Bool = false
    public var eveningFedStamp: Date?
    public var feedDate: Date?
    public var morningFed: Bool = false
    public var morningFedStamp: Date?
    public var pet: Pet?

    public init(
        eveningFed: Bool = false,
        eveningFedStamp: Date? = nil,
        feedDate: Date? = nil,
        morningFed: Bool = false,
        morningFedStamp: Date? = nil
    ) {
        self.eveningFed = eveningFed
        self.eveningFedStamp = eveningFedStamp
        self.feedDate = feedDate
        self.morningFed = morningFed
        self.morningFedStamp = morningFedStamp
    }

}

public extension Feed {
    @MainActor static var preview: Feed {
        Feed(
            eveningFed: true,
            eveningFedStamp: .eightPM,
            feedDate: .eightPM,
            morningFed: true,
            morningFedStamp: .eightAM
        )
    }

    @MainActor static var previews: [Feed] {
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

 #Playground {
    await MainActor.run {
        _ = Feed.previews
        _ = Feed.preview
    }
 }
