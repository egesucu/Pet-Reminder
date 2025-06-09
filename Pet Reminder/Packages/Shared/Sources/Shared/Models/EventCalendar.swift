//
//  EventCalendar.swift
//  Shared
//
//  Created by Sucu, Ege on 19.05.2025.
//

import Foundation

public struct EventCalendar: Identifiable, Equatable, Sendable, Hashable {
    
    public let id: UUID = UUID()
    public let title: String
    
    public init(_ title: String) {
        self.title = title
    }
}

extension EventCalendar: CustomStringConvertible {
    public var description: String {
        title
    }
}
