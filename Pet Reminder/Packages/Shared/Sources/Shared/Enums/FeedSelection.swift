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

public extension FeedSelection {
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
