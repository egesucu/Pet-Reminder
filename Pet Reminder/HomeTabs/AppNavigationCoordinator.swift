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

    // Only the app-intent inbox uses this target. Scene coordinators own their state.
    weak var activeWindow: AppNavigationCoordinator?

    func connect(to window: AppNavigationCoordinator) {
        activeWindow = window
        if let pendingRequest {
            window.open(pendingRequest.destination)
            self.pendingRequest = nil
        }
    }

    func disconnect(from window: AppNavigationCoordinator) {
        if activeWindow === window { activeWindow = nil }
    }

    func openPet(id: UUID) { open(.pet(id)) }
    func open(_ destination: PetRoute) {
        if let activeWindow {
            activeWindow.open(destination)
            return
        }
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
