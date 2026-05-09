//
//  FeedSelection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.06.2024.
//  Copyright © 2024 Ege Sucu. All rights reserved.
//
import Foundation
import SwiftData

public enum FeedSelection: Codable, CaseIterable, CustomStringConvertible {
    case morning
    case evening
    case both

    public var description: String {
        return switch self {
        case .morning:
            "Morning"
        case .evening:
            "Evening"
        case .both:
            "Both"
        }
    }
}

// Keep UI-facing API isolated to the main actor without isolating Codable.
@MainActor
public extension FeedSelection {
    var localized: LocalizedStringResource {
        switch self {
        case .morning:
            .feedSelectionMorning
        case .evening:
            .feedSelectionEvening
        case .both:
            .feedSelectionBoth
        }
    }
}

public extension FeedSelection {
    static func fromLegacyChoice(_ choice: Int) -> Self {
        switch choice {
        case 0: return .morning
        case 1: return .evening
        default: return .both
        }
    }

    func fetchFeedSelection(from: String) -> Self {
        return switch from {
        case FeedSelection.evening.description:
            .evening
        case FeedSelection.both.description:
            .both
        default:
            .morning
        }
    }
}
