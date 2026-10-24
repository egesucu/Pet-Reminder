import Foundation
import Observation
import Pets
import Shared
import SwiftData

@MainActor
@Observable
final class AppNavigationCoordinator {
    var selectedTab: PetReminderTabs = .home
    private(set) var pendingRequest: PetRouteRequest?

    func openPet(id: UUID) { open(.pet(id)) }
    func open(_ destination: PetRoute) {
        selectedTab = .home
        pendingRequest = PetRouteRequest(destination)
    }

    func handle(_ url: URL) {
        guard url.scheme?.lowercased() == "petreminder", let host = url.host?.lowercased() else { return }
        switch host {
        case "home":
            selectedTab = .home
            if let name = url.pathComponents.first(where: { $0 != "/" }), !name.isEmpty {
                open(.namedPet(name))
            }
        case "add": open(.addPet)
        case "events": selectedTab = .events
        case "findvet": selectedTab = .vet
        case "settings": selectedTab = .settings
        default: break
        }
    }

    func consume(_ request: PetRouteRequest) {
        if pendingRequest?.token == request.token { pendingRequest = nil }
    }

    func resolvePendingPet(in context: ModelContext) throws -> Pet? {
        guard let id = pendingRequest?.petID else { return nil }
        return try PetRouteResolver.resolve(id: id, in: context)
    }
}
