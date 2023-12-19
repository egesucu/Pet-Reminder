//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

extension Feed {
  var wrappedFeedDate: Date {
    feedDate ?? .now
  }

  var wrappedMorningFedStamp: Date {
    morningFedStamp ?? .now
  }

  var wrappedEveningFedStamp: Date {
    eveningFedStamp ?? .now
  }

  var preview: Feed {
    Feed(
      eveningFed: true,
      eveningFedStamp: .eightPM,
      feedDate: .eightPM,
      morningFed: true,
      morningFedStamp: .eightAM)
  }

  var previews: [Feed] {
    var feeds: [Feed] = []
    for _ in [0...4] {
      let date = Date.randomDate()
      let feed = Feed(
        eveningFed: true,
        eveningFedStamp: date,
        feedDate: date,
        morningFed: true,
        morningFedStamp: date)
      feeds.append(feed)
    }
    return feeds
  }

}
