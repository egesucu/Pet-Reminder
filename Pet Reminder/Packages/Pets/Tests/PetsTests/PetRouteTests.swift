import Foundation
import SwiftData
import Testing
import Shared
@testable import Pets

@MainActor
struct PetRouteTests {
    @Test("Legacy names retain case, diacritic and slug matching")
    func legacyNames() {
        let pet = Pet(name: "Lúna Belle")
        #expect(PetRouteResolver.resolve(name: "LUNA BELLE", among: [pet]) === pet)
        #expect(PetRouteResolver.resolve(name: "luna-belle", among: [pet]) === pet)
        #expect(PetRouteResolver.resolve(name: "missing", among: [pet]) == nil)
    }

    @Test("UUID routes survive rename and stop resolving after deletion")
    func durableIdentity() throws {
        let container = try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
        let pet = Pet(name: "Luna")
        let id = try #require(pet.intentID)
        container.mainContext.insert(pet)
        try container.mainContext.save()
        pet.name = "Bella"
        try container.mainContext.save()
        #expect(try PetRouteResolver.resolve(id: id, in: container.mainContext)?.name == "Bella")
        container.mainContext.delete(pet)
        try container.mainContext.save()
        #expect(try PetRouteResolver.resolve(id: id, in: container.mainContext) == nil)
    }
}
