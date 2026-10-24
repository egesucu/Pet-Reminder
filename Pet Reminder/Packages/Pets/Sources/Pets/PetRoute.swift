import Foundation
import SwiftData
import Shared

public enum PetRoute: Equatable, Sendable {
    case pet(UUID)
    case namedPet(String)
    case addPet
}

public struct PetRouteRequest: Equatable, Sendable {
    public let token: UUID
    public let destination: PetRoute
    public var petID: UUID? {
        if case .pet(let id) = destination { return id }
        return nil
    }
    public init(_ destination: PetRoute, token: UUID = UUID()) {
        self.destination = destination
        self.token = token
    }
}

/// Resolves durable identity using saved data, including IDs backfilled in another context.
@MainActor
public enum PetRouteResolver {
    public static func resolve(id: UUID, in context: ModelContext) throws -> Pet? {
        let id: UUID? = id
        let readContext = ModelContext(context.container)
        let descriptor = FetchDescriptor<Pet>(predicate: #Predicate { $0.intentID == id })
        guard let savedPet = try readContext.fetch(descriptor).first else { return nil }
        return context.model(for: savedPet.persistentModelID) as? Pet
    }

    static func resolve(name raw: String, among pets: [Pet]) -> Pet? {
        if let exact = pets.first(where: {
            $0.name.compare(raw, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) { return exact }
        func slug(_ value: String) -> String {
            let folded = value.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return String(folded.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) })
        }
        let target = slug(raw)
        return pets.first { slug($0.name) == target }
    }
}
