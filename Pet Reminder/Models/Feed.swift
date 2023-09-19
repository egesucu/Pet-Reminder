//
//  Feed.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
//

import Foundation
import SwiftData

@Model public class Feed {
    var eveningFed = false
    var eveningFedStamp: Date?
    var feedDate: Date?
    var morningFed = false
    var morningFedStamp: Date?
    var pet: Pet?

    public init() { }

}
