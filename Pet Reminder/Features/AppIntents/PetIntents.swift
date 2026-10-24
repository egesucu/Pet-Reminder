import AppIntents
import Foundation
import Shared
import SharedUI
import PetCare

nonisolated enum Meal: String, AppEnum {
    case morning, evening

    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Meal"
    nonisolated static let caseDisplayRepresentations: [Meal: DisplayRepresentation] = [
        .morning: "Morning", .evening: "Evening"
    ]

    var selection: FeedSelection { self == .morning ? .morning : .evening }
}

nonisolated enum PetIntentError: LocalizedError {
    case missingPet, unavailableData, unsupportedMeal, failedSave

    var errorDescription: String? {
        switch self {
        case .missingPet: String(localized: "This pet is no longer available. Choose a pet again.")
        case .unavailableData: String(localized: "Pet data is unavailable. Open Pet Reminder and try again.")
        case .unsupportedMeal: String(localized: "This meal is not in the pet's feeding schedule.")
        case .failedSave: String(localized: "The change could not be saved. Please try again.")
        }
    }
}

@MainActor
func intentOperation<T>(_ operation: () throws -> T) throws -> T {
    do {
        return try operation()
    } catch let error as PetCareError {
        switch error {
        case .petNotFound: throw PetIntentError.missingPet
        case .dataUnavailable: throw PetIntentError.unavailableData
        case .unsupportedMeal: throw PetIntentError.unsupportedMeal
        case .saveFailed: throw PetIntentError.failedSave
        }
    }
}

struct FindPetsIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Find Pets"
    nonisolated static let description = IntentDescription("Find your pets by name, or return all pets.")
    nonisolated static let supportedModes: IntentModes = .background
    nonisolated static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Name") var name: String?
    @Dependency var service: PetCareService

    nonisolated static var parameterSummary: some ParameterSummary { Summary("Find pets matching \(\.$name)") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[PetEntity]> {
        let pets = try intentOperation { try service.pets(matching: name).map(PetEntity.init) }
        return .result(value: pets)
    }
}

struct GetFeedingStatusIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Get Today's Feeding Status"
    nonisolated static let description = IntentDescription("Check which meals your pet has received today.")
    nonisolated static let supportedModes: IntentModes = .background
    nonisolated static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Pet") var pet: PetEntity
    @Dependency var service: PetCareService

    nonisolated static var parameterSummary: some ParameterSummary { Summary("Get today's feeding status for \(\.$pet)") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<PetFeedingStatusEntity> & ProvidesDialog {
        let status = try intentOperation { PetFeedingStatusEntity(try service.feedingStatus(id: pet.id)) }
        return .result(value: status, dialog: status.dialog)
    }
}

struct MarkMealFedIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Mark Meal Fed"
    nonisolated static let description = IntentDescription("Record a morning or evening meal for today. Repeating this action keeps the existing completion.")
    nonisolated static let supportedModes: IntentModes = .background
    nonisolated static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Pet") var pet: PetEntity
    @Parameter(title: "Meal") var meal: Meal
    @Dependency var service: PetCareService

    nonisolated static var parameterSummary: some ParameterSummary { Summary("Mark \(\.$meal) fed for \(\.$pet)") }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<PetFeedingStatusEntity> & ProvidesDialog {
        let status = try intentOperation { PetFeedingStatusEntity(try service.markFed(id: pet.id, meal: meal.selection)) }
        return .result(value: status, dialog: status.dialog)
    }
}

struct OpenPetIntent: OpenIntent {
    nonisolated static let title: LocalizedStringResource = "Open Pet"
    nonisolated static let description = IntentDescription("Open your pet's details in Pet Reminder.")
    nonisolated static let supportedModes: IntentModes = .foreground
    nonisolated static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Pet") var target: PetEntity
    @Dependency var service: PetCareService
    @Dependency var navigation: AppNavigationCoordinator

    nonisolated static var parameterSummary: some ParameterSummary { Summary("Open \(\.$target)") }

    @MainActor
    func perform() async throws -> some IntentResult {
        let pet = try intentOperation { try service.pet(id: target.id) }
        navigation.openPet(id: pet.id)
        return .result()
    }
}
