//
//  PetSchemaV4.swift
//  Shared
//
//  Created by Sucu, Ege on 08.06.26.
//

import Foundation
import SwiftData

public enum PetSchemaV4: VersionedSchema {
    public static let versionIdentifier = Schema.Version(4, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    public final class Pet {
        public var name: String = String.empty
        public var birthday: Date = Date.now
        public var createdAt: Date?
        public var image: Data?
        public var breed: String?
        private var feedSelectionRaw: String = "both"
        // Keep the original CloudKit field name; CloudKit-backed stores can't rename properties.
        private var petTypeName: Kind.RawValue = Kind.other.rawValue

        @Relationship(inverse: \Feed.pet) public var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) public var vaccines: [Vaccine]?

        public init(
            birthday: Date = Date(),
            name: String = .empty,
            createdAt: Date? = nil,
            feedSelection: FeedSelection = .both,
            image: Data? = nil,
            breed: String? = nil,
            feeds: [Feed]? = nil,
            vaccines: [Vaccine]? = nil,
            kind: Kind = .dog
        ) {
            self.birthday = birthday
            self.name = name
            self.createdAt = createdAt
            self.breed = breed
            self.image = image
            self.feeds = feeds
            self.vaccines = vaccines
            self.kind = kind
            self.feedSelection = feedSelection
        }

        public var feedSelection: FeedSelection {
            get {
                Self.feedSelection(from: feedSelectionRaw)
            }
            set {
                feedSelectionRaw = Self.rawString(for: newValue)
            }
        }

        public var kind: Kind {
            get { .init(rawValue: petTypeName) ?? .other }
            set { petTypeName = newValue.rawValue }
        }

        private static func rawString(for selection: FeedSelection) -> String {
            switch selection {
            case .morning:
                return "morning"
            case .evening:
                return "evening"
            case .both:
                return "both"
            }
        }

        private static func feedSelection(from raw: String) -> FeedSelection {
            switch raw {
            case "morning":
                return .morning
            case "evening":
                return .evening
            default:
                return .both
            }
        }
    }
    // Keep historical relationships within this schema; never reference the current Pet alias.

    @Model
    public class Feed: Identifiable {
        public var id: UUID = UUID()
        public var eveningFed: Bool = false
        public var eveningFedStamp: Date?
        public var feedDate: Date?
        public var morningFed: Bool = false
        public var morningFedStamp: Date?
        public var pet: Pet?

        public init(
            id: UUID = UUID(),
            eveningFed: Bool = false,
            eveningFedStamp: Date? = nil,
            feedDate: Date? = nil,
            morningFed: Bool = false,
            morningFedStamp: Date? = nil
        ) {
            self.id = id
            self.eveningFed = eveningFed
            self.eveningFedStamp = eveningFedStamp
            self.feedDate = feedDate
            self.morningFed = morningFed
            self.morningFedStamp = morningFedStamp
        }

    }

    @Model
    public class Vaccine {
        public var date: Date = Date.now
        public var name: String = String.empty
        public var pet: Pet?

        public init(
            date: Date = Date.now,
            name: String = .empty
        ) {
            self.date = date
            self.name = name
        }
    }

}
