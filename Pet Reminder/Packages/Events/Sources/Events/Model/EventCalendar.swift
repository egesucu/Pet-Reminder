import EventKit
import SwiftUI

public struct EventCalendar: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let color: Color

    public init(_ title: String) {
        self.id = title
        self.title = title
        self.color = .accentColor
    }

    init(id: String, title: String, color: Color = .accentColor) {
        self.id = id
        self.title = title
        self.color = color
    }

    init(calendar: EKCalendar) {
        id = calendar.calendarIdentifier
        title = calendar.title
        color = calendar.cgColor.map { Color(cgColor: $0) } ?? .accentColor
    }
}

extension EventCalendar: CustomStringConvertible {
    public var description: String { title }
}
