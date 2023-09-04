//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation

extension Feed {
    var wrappedFeedDate: Date {
        self.feedDate ?? .now
    }
    
    var wrappedMorningFedStamp: Date {
        self.morningFedStamp ?? .now
    }
    
    var wrappedEveningFedStamp: Date {
        self.eveningFedStamp ?? .now
    }
}
