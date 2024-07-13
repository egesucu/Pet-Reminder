//
//  FeedSelection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 20.06.2024.
//  Copyright © 2024 Ege Sucu. All rights reserved.
//
import Foundation
import SwiftData

public enum FeedSelection {
    case morning
    case evening
    case both
}

extension FeedSelection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .morning:
            return "Morning"
        case .evening:
            return "Evening"
        case .both:
            return "Both"
        }
    }
}

extension FeedSelection: Codable {
    
}

extension FeedSelection: CaseIterable {}

public extension FeedSelection {
    func fetchFeedSelection(from: String) -> Self {
        switch from {
        case FeedSelection.morning.description:
            return .morning
        case FeedSelection.evening.description:
            return .evening
        case FeedSelection.both.description:
            return .both
        default:
            return .morning
        }
    }
}
