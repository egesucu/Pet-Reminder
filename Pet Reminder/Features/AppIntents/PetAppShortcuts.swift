import AppIntents

struct PetAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenPetIntent(),
            phrases: ["Open \(\.$target) in \(.applicationName)", "Open a pet in \(.applicationName)"],
            shortTitle: "Open Pet",
            systemImageName: "pawprint"
        )
        AppShortcut(
            intent: GetFeedingStatusIntent(),
            phrases: ["Check \(\.$pet)'s feeding in \(.applicationName)", "Check feeding in \(.applicationName)"],
            shortTitle: "Check Feeding",
            systemImageName: "checklist"
        )
        AppShortcut(
            intent: MarkMealFedIntent(),
            phrases: ["Record a meal in \(.applicationName)", "Record a meal for \(\.$pet) in \(.applicationName)"],
            shortTitle: "Record Meal",
            systemImageName: "fork.knife"
        )
    }
}
