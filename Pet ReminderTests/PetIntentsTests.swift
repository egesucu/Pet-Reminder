import Pets
import AppIntents
import Foundation
import Shared
import PetCare
import SwiftData
import Testing
@testable import Pet_Reminder

@MainActor
struct PetIntentsTests {
    private func container() throws -> ModelContainer {
        try ModelContainer(for: Pet.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none))
    }

    @Test("Queries return all ambiguous matches and resolve references by durable identity")
    func queries() async throws {
        let container = try container()
        let service = PetCareService(container: container)
        let query = PetEntityQuery()
        query.service = service
        #expect(try await query.suggestedEntities().isEmpty)
        let first = Pet(name: "Lúna")
        let second = Pet(name: "Luna")
        container.mainContext.insert(first)
        container.mainContext.insert(second)
        try container.mainContext.save()
        let matches = try await query.entities(matching: "LUNA")
        #expect(matches.count == 2)
        let id = try #require(first.intentID)
        first.name = "Renamed"
        try container.mainContext.save()
        #expect(try await query.entities(for: [id]).first?.name == "Renamed")
        container.mainContext.delete(first)
        try container.mainContext.save()
        #expect(try await query.entities(for: [id]).isEmpty)
    }

    @Test("Actions re-fetch current data and return structured feeding results")
    func feedingActions() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let date = Date.now
        let service = PetCareService(container: container, clock: { date })
        let entity = PetEntity(try service.pet(id: #require(pet.intentID)))
        pet.name = "Renamed"
        try container.mainContext.save()
        let find = FindPetsIntent()
        find.service = service
        #expect(try await find.perform().value?.count == 1)
        let mark = MarkMealFedIntent()
        mark.pet = entity
        mark.meal = .morning
        mark.service = service
        let first = try #require(await mark.perform().value)
        let second = try #require(await mark.perform().value)
        #expect(first.morningFed)
        #expect(first.pet.name == "Renamed")
        #expect(first.morningTime == date)
        #expect(second.morningTime == first.morningTime)
        let get = GetFeedingStatusIntent()
        get.pet = entity
        get.service = service
        #expect(try await get.perform().value?.morningFed == true)
        #expect(try await get.perform().value?.eveningFed == false)
        container.mainContext.delete(pet)
        try container.mainContext.save()
        await #expect(throws: PetIntentError.missingPet) { try await get.perform() }
    }

    @Test("Open Pet queues UUID requests and repeated requests get new tokens")
    func openPet() async throws {
        let container = try container()
        let pet = Pet(name: "Luna")
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let service = PetCareService(container: container)
        let navigation = AppNavigationCoordinator()
        let intent = OpenPetIntent()
        intent.target = PetEntity(try service.pet(id: #require(pet.intentID)))
        intent.service = service
        intent.navigation = navigation
        _ = try await intent.perform()
        let first = try #require(navigation.pendingRequest)
        _ = try await intent.perform()
        let second = try #require(navigation.pendingRequest)
        #expect(first.petID == pet.intentID)
        #expect(second.token != first.token)
        navigation.consume(first)
        #expect(navigation.pendingRequest == second)
        navigation.consume(second)
        #expect(navigation.pendingRequest == nil)
    }

    @Test("Intent policies require authentication and use the intended execution modes")
    func policies() {
        #expect(FindPetsIntent.authenticationPolicy == .requiresAuthentication)
        #expect(GetFeedingStatusIntent.authenticationPolicy == .requiresAuthentication)
        #expect(MarkMealFedIntent.authenticationPolicy == .requiresAuthentication)
        #expect(OpenPetIntent.authenticationPolicy == .requiresAuthentication)
        #expect(MarkMealFedIntent.supportedModes == .background)
        #expect(OpenPetIntent.supportedModes == .foreground)
    }

    @Test("Navigation resolves imported IDs even when the UI has cached a pet without an ID")
    func resolvesBackfilledPet() throws {
        let container = try container()
        let pet = Pet(name: "Legacy")
        pet.intentID = nil
        container.mainContext.insert(pet)
        try container.mainContext.save()
        let service = PetCareService(container: container)
        let snapshot = try #require(service.pets().first)
        let navigation = AppNavigationCoordinator()
        navigation.openPet(id: snapshot.id)
        let candidate = try navigation.resolvePendingPet(in: container.mainContext)
        let resolved = try #require(candidate)
        #expect(resolved.persistentModelID == pet.persistentModelID)
        #expect(navigation.pendingRequest != nil) // Resolution does not consume an unhandled request.
    }
}
