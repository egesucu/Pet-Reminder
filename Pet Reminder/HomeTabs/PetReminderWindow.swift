import SwiftUI
import Intro
import Events
import VetFinder
import Pets
import Shared

/// UI state belongs to a window; persisted pet data and notifications are shared.
struct PetReminderWindow: View {
    @Binding var petID: UUID?
    let intentInbox: AppNavigationCoordinator
    let isCapturingScreenshots: Bool
    @AppStorage(Strings.helloSeen) private var helloSeen = false
    @SceneStorage("window.initialized") private var initialized = false
    @SceneStorage("window.tab") private var storedTab = PetReminderTabs.home.rawValue
    @State private var navigation = AppNavigationCoordinator()
    @State private var eventManager = EventManager()
    @State private var vetService = VetServiceImplementation()

    var body: some View {
        Group {
            if helloSeen || isCapturingScreenshots {
                HomeManager(windowPetID: $petID)
            } else {
                IntroView { helloSeen = true }
            }
        }
        .environment(navigation)
        .environment(eventManager)
        .environment(vetService)
        .focusedSceneValue(navigation)
        .onOpenURL { navigation.handle($0) }
        .task {
            let restoredTab = PetReminderTabs(rawValue: storedTab) ?? .home
            // An incoming Intent or URL takes priority over saved navigation.
            if navigation.pendingRequest == nil, navigation.selectedTab == .home {
                if let petID { navigation.openPet(id: petID) }
                navigation.selectedTab = initialized ? restoredTab : (petID == nil ? restoredTab : .home)
            }
            initialized = true
        }
        .onChange(of: navigation.selectedTab) { _, tab in storedTab = tab.rawValue }
        .background(WindowActivationObserver(
            activate: { intentInbox.connect(to: navigation) },
            deactivate: { intentInbox.disconnect(from: navigation) }
        ))
    }
}

struct PetWindowCommands: Commands {
    @FocusedValue(AppNavigationCoordinator.self) private var navigation
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            if supportsMultipleWindows {
                Button(SharedStrings.resource("New Window")) { openWindow(id: "main") }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }
        CommandMenu(Text(SharedStrings.resource("Navigate"))) {
            tab(SharedStrings.homeTabTitle, .home, key: "1")
            tab(SharedStrings.eventTabTitle, .events, key: "2")
            tab(SharedStrings.settingsTabTitle, .settings, key: "3")
            tab(SharedStrings.findVetTitle, .vet, key: "4")
        }
    }

    private func tab(_ title: LocalizedStringResource, _ tab: PetReminderTabs, key: KeyEquivalent) -> some View {
        Button(title) { navigation?.selectedTab = tab }
            .keyboardShortcut(key)
            .disabled(navigation == nil)
    }
}

/// Each explicit new-window action creates a distinct scene, even if another
/// full app window has the same pet selected while showing a different tab.
nonisolated struct PetWindowState: Codable, Hashable {
    let instanceID: UUID
    var petID: UUID?
    init(petID: UUID?) {
        self.instanceID = UUID()
        self.petID = petID
    }
}
