import Foundation
import Observation
import SwiftData

/// Refreshes only feeding UI models, leaving the app's editing context intact.
@MainActor
@Observable
public final class PetCareSession {
    @ObservationIgnored private let container: ModelContainer
    public private(set) var context: ModelContext
    public private(set) var pet: Pet?

    public init(container: ModelContainer) {
        self.container = container
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    public func reload(id: UUID) throws {
        let freshContext = ModelContext(container)
        freshContext.autosaveEnabled = false
        let requestedID: UUID? = id
        let descriptor = FetchDescriptor<Pet>(predicate: #Predicate { $0.intentID == requestedID })
        let freshPet = try freshContext.fetch(descriptor).first
        context = freshContext
        pet = freshPet
    }
}
