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

extension FeedSelection: Codable {}

extension FeedSelection: CaseIterable {}

public extension FeedSelection {
    func fetchFeedSelection(from: String) -> Self {
        return switch from {
        case FeedSelection.morning.description:
            .morning
        case FeedSelection.evening.description:
            .evening
        case FeedSelection.both.description:
            .both
        default:
            .morning
        }
    }
}
