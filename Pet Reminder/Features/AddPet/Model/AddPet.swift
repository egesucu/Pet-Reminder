//
//  AddPet.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 10.02.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

/// Model backing the Add Pet flow.
@Observable
@MainActor
class AddPet {
    
    /// Tracks the result of a save attempt.
    enum SaveState {
        case none, success, failure
    }
    
    /// Entered pet name.
    var name: String
    /// Selected birthday for the pet.
    var birthday: Date = .now
    /// Selected pet type.
    var type: PetType = .dog
    /// Raw image data from the picker.
    var selectedImageData: Data?
    /// Which feed reminders are enabled.
    var feedSelection: FeedSelection
    /// Morning feed reminder time.
    var morningFeed: Date
    /// Evening feed reminder time.
    var eveningFeed: Date
    /// Whether the name currently passes validation.
    var nameIsValid: Bool
    /// Whether a pet with this name already exists.
    var petExists: Bool
    /// Result state for the last save attempt.
    var saveState: SaveState = .none
    
    /// Creates a new Add Pet model with configurable defaults.
    init(
        name: String = "",
        birthday: Date = .now,
        selectedImageData: Data? = nil,
        type: PetType = .dog,
        feedSelection: FeedSelection = .both,
        morningFeed: Date = .eightAM,
        eveningFeed: Date = .eightPM,
        nameIsValid: Bool = false,
        petExists: Bool = false
    ) {
        self.name = name
        self.birthday = birthday
        self.type = type
        self.selectedImageData = selectedImageData
        self.feedSelection = feedSelection
        self.morningFeed = morningFeed
        self.eveningFeed = eveningFeed
        self.nameIsValid = nameIsValid
        self.petExists = petExists
    }
    
    /// Returns true when the pet can be saved.
    var petCanBeSaved: Bool {
        nameIsValid && !petExists
    }
    
}
