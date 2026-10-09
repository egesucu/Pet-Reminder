import Foundation
import Observation
import Shared
import SwiftData

/// Retains a request across launch and onboarding until a home view has handled it.
@MainActor
@Observable
final class AppNavigationCoordinator {
    struct PetRequest: Equatable {
        let token = UUID()
        let petID: UUID
    }

    private(set) var pendingPet: PetRequest?

    func openPet(id: UUID) {
        pendingPet = PetRequest(petID: id)
    }

    func consume(_ request: PetRequest) {
        if pendingPet?.token == request.token {
            pendingPet = nil
        }
    }

    /// Resolve through the store when the UI still has a cached pre-backfill pet.
    func resolvePendingPet(in context: ModelContext) throws -> Pet? {
        guard let request = pendingPet else { return nil }
        let id: UUID? = request.petID
        let readContext = ModelContext(context.container)
        let descriptor = FetchDescriptor<Pet>(predicate: #Predicate { $0.intentID == id })
        guard let savedPet = try readContext.fetch(descriptor).first else { return nil }
        return context.model(for: savedPet.persistentModelID) as? Pet
    }
}
