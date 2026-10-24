import Foundation
import Testing
import Pets
@testable import Pet_Reminder

@MainActor
struct AppNavigationTests {
    @Test("Legacy links retain decoded names until the home screen handles them")
    func namedPetLink() throws {
        let navigation = AppNavigationCoordinator()
        navigation.selectedTab = .settings
        navigation.handle(try #require(URL(string: "petreminder://home/M%C4%B1s%C4%B1r")))
        #expect(navigation.selectedTab == .home)
        #expect(navigation.pendingRequest?.destination == .namedPet("Mısır"))
        let request = try #require(navigation.pendingRequest)
        navigation.consume(request)
        #expect(navigation.pendingRequest == nil)
    }

    @Test("Add requests survive until acknowledged and stale acknowledgements preserve newer requests")
    func addPetLink() throws {
        let navigation = AppNavigationCoordinator()
        let url = try #require(URL(string: "petreminder://add"))
        navigation.handle(url)
        let first = try #require(navigation.pendingRequest)
        navigation.handle(url)
        let second = try #require(navigation.pendingRequest)
        #expect(first.destination == .addPet)
        #expect(second.token != first.token)
        navigation.consume(first)
        #expect(navigation.pendingRequest == second)
        navigation.consume(second)
        #expect(navigation.pendingRequest == nil)
    }

    @Test("Tab links and unrelated URLs preserve pending pet requests")
    func tabLinks() throws {
        let navigation = AppNavigationCoordinator()
        navigation.openPet(id: UUID())
        let pending = navigation.pendingRequest
        for (host, tab) in [("events", PetReminderTabs.events), ("findVet", .vet), ("settings", .settings), ("home", .home)] {
            navigation.handle(try #require(URL(string: "petreminder://\(host)")))
            #expect(navigation.selectedTab == tab)
            #expect(navigation.pendingRequest == pending)
        }
        navigation.handle(try #require(URL(string: "https://home/Luna")))
        navigation.handle(try #require(URL(string: "petreminder://unknown")))
        #expect(navigation.selectedTab == .home)
        #expect(navigation.pendingRequest == pending)
    }
}
