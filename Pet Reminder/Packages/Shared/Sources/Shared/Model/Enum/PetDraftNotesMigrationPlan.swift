import Foundation
import SwiftData

/// Persisted model used by the development build that stored one string per pet.
enum PetDraftNotesSchema: VersionedSchema {
    static let versionIdentifier = Schema.Version(6, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Pet.self]
    }

    @Model
    final class Pet {
        // Optional storage allows older CloudKit records to arrive without an ID.
        var intentID: UUID?
        var name: String = String.empty
        var birthday: Date = Date.now
        var createdAt: Date?
        var image: Data?
        var breed: String?
        var notes: String?
        private var feedSelectionRaw: String = "both"
        // Keep the original CloudKit field name; CloudKit-backed stores can't rename properties.
        private var petTypeName: Kind.RawValue = Kind.other.rawValue

        @Relationship(inverse: \Feed.pet) var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) var vaccines: [Vaccine]?

        init(name: String, intentID: UUID, notes: String?) {
            self.name = name
            self.intentID = intentID
            self.notes = notes
        }
    }

    @Model
    class Feed: Identifiable {
        var id: UUID = UUID()
        var eveningFed: Bool = false
        var eveningFedStamp: Date?
        var feedDate: Date?
        var morningFed: Bool = false
        var morningFedStamp: Date?
        var pet: Pet?

        init() {}
    }

    @Model
    class Vaccine {
        var date: Date = Date.now
        var name: String = String.empty
        var pet: Pet?

        init() {}
    }
}

/// Isolated upgrade path for draft stores. Current and shipped stores use PetMigrationPlan.
public enum PetDraftNotesMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [PetDraftNotesSchema.self, PetDraftNotesBridgeSchema.self, PetSchemaV6.self]
    }

    public static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: PetDraftNotesSchema.self, toVersion: PetDraftNotesBridgeSchema.self),
            .custom(
                fromVersion: PetDraftNotesBridgeSchema.self,
                toVersion: PetSchemaV6.self,
                willMigrate: { context in
                    for pet in try context.fetch(FetchDescriptor<PetDraftNotesBridgeSchema.Pet>()) {
                        guard let notes = pet.notes else { continue }
                        if !notes.isEmpty {
                            context.insert(PetDraftNotesBridgeSchema.PetNote(text: notes, pet: pet))
                        }
                        pet.notes = nil
                    }
                    try context.save()
                },
                didMigrate: nil
            )
        ]
    }
}

enum PetDraftNotesBridgeSchema: VersionedSchema {
    static let versionIdentifier = Schema.Version(6, 0, 1)

    static var models: [any PersistentModel.Type] {
        [Pet.self, PetNote.self]
    }

    @Model
    final class Pet {
        // Optional storage allows older CloudKit records to arrive without an ID.
        var intentID: UUID?
        var name: String = String.empty
        var birthday: Date = Date.now
        var createdAt: Date?
        var image: Data?
        var breed: String?
        var notes: String?
        private var feedSelectionRaw: String = "both"
        // Keep the original CloudKit field name; CloudKit-backed stores can't rename properties.
        private var petTypeName: Kind.RawValue = Kind.other.rawValue

        @Relationship(deleteRule: .cascade, inverse: \PetNote.pet) var migratedNotes: [PetNote]?
        @Relationship(inverse: \Feed.pet) var feeds: [Feed]?
        @Relationship(inverse: \Vaccine.pet) var vaccines: [Vaccine]?

        init(name: String, intentID: UUID, notes: String?) {
            self.name = name
            self.intentID = intentID
            self.notes = notes
        }
    }

    @Model
    class Feed: Identifiable {
        var id: UUID = UUID()
        var eveningFed: Bool = false
        var eveningFedStamp: Date?
        var feedDate: Date?
        var morningFed: Bool = false
        var morningFedStamp: Date?
        var pet: Pet?

        init() {}
    }

    @Model
    class Vaccine {
        var date: Date = Date.now
        var name: String = String.empty
        var pet: Pet?

        init() {}
    }
    @Model
    final class PetNote {
        var text: String = ""
        var createdAt: Date = Date.now
        var pet: Pet?

        init(text: String, pet: Pet) {
            self.text = text
            self.pet = pet
        }
    }
}
