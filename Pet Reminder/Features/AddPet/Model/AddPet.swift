//
//  AddPet.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 10.02.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

@Observable
@MainActor
class AddPet {
    
    var selectedImageData: Data?
    var feedSelection: FeedSelection = .both
    var morningFeed: Date = .eightAM
    var eveningFeed: Date = .eightPM
    var nameIsValid = false
    var petExists = false
    var saveFailed = false
    var saveSuccess = false
    
    var petCanBeSaved: Bool {
        nameIsValid && !petExists
    }
    
}
