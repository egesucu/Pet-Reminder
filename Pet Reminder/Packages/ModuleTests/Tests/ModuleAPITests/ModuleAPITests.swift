import Foundation
import SwiftData
import SwiftUI
import MapKit
import UserNotifications
import Testing
import Shared
import SharedUI
import PetCare
import Reminders
import Pets
import Events
import VetFinder
import Intro
import Settings
import PreviewSupport

@MainActor
private final class NoNotifications: NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool { false }
    func pendingNotificationRequests() async -> [UNNotificationRequest] { [] }
    func add(_ request: UNNotificationRequest) async throws {}
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {}
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {}
    func removeAllPendingNotificationRequests() {}
}

@MainActor
private struct NoLocation: VetService {
    func requestMapPermissions() async {}
    func setViewStatus() -> MapViewStatus { .locationNotAllowed }
    func findUserLocation() -> MapCameraPosition { .automatic }
    func searchLocations(with searchTerm: String, near userLocation: MapCameraPosition) async -> [Pin] { [] }
    func stopUpdating() {}
}

@MainActor
struct ModuleAPITests {
    @Test("An external consumer can compose feature roots and construct service snapshots")
    func publicComposition() {
        let reminders = NotificationManager(notificationCenter: NoNotifications(), authorizationStatusProvider: { .denied })
        let request = PetRouteRequest(.addPet)
        _ = PetList(request: request, onRequestHandled: { _ in }).notification(reminders)
        _ = Settings(managePets: { AnyView(PetChangeList()) }).notification(reminders)
        _ = EventList().environment(EventManager(isDemo: true))
        _ = FindVet(service: NoLocation())
        _ = IntroView(onContinue: {})
        let pet = PetSnapshot(id: UUID(), name: "Luna", kind: .dog, breed: nil, birthday: .now, schedule: .both)
        let feeding = FeedingSnapshot(pet: pet, day: .now, morningFed: false, eveningFed: false, morningTime: nil, eveningTime: nil)
        #expect(feeding.pet.id == pet.id)
        #expect(request.destination == .addPet)
    }

    @Test("Localization resolves from the package bundle rather than the test host")
    func localizationBundle() {
        var text = SharedStrings.homeTabTitle
        text.locale = Locale(identifier: "tr")
        #expect(String(localized: text) == "Dostların")
        var bird = SharedStrings.bird
        bird.locale = Locale(identifier: "tr")
        #expect(String(localized: bird) == "Kuş")
        var literal = SharedStrings.resource("Select a pet")
        literal.locale = Locale(identifier: "tr")
        #expect(String(localized: literal) == "Bir dostunu seç")
    }

    @Test("All default pet images resolve across the resource boundary")
    func defaultImages() {
        for kind in Kind.allCases {
            #expect(kind.uiImage.size.width > 0)
            #expect(kind.uiImage.size.height > 0)
        }
    }

    @Test("Preview data is repeatable and uses an isolated memory store")
    func isolatedPreviews() throws {
        let first = Pet.previews
        let second = Pet.previews
        #expect(first.map(\.name) == second.map(\.name))
        #expect(first.map(\.birthday) == second.map(\.birthday))
        #expect(first[0] !== second[0])
        #expect(first.allSatisfy { $0.feeds?.allSatisfy { $0.pet != nil } == true })
        let container = PreviewData.emptyContainer
        let isolated = container.configurations.allSatisfy { $0.isStoredInMemoryOnly }
        #expect(isolated)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Pet>()) == 0)
    }
}
