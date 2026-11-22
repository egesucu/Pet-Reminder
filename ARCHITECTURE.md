# Modules and integration contracts

Each production module is a separate local Swift package under `Pet Reminder/Packages`, with its own manifest and tests. All packages require iOS 27 and Swift tools 6.4. The `Shared` package keeps its original path and module name because it owns persisted SwiftData types.

| Package | Responsibility | Production dependencies |
| --- | --- | --- |
| Shared | Persisted models, migration chain, common values, resources | None |
| SharedUI | Reusable views, modifiers, image and presentation helpers | Shared |
| PetCare | Feeding operations, snapshots, operation contexts and UI refresh sessions | Shared |
| Reminders | Local notifications and authorization | Shared |
| Pets | Creation, editing, details, feeding and vaccination screens | Shared, SharedUI, PetCare, Reminders |
| Events | Calendar access, calendar models and event screens | Shared, SharedUI |
| VetFinder | Location, nearby search and maps | Shared, SharedUI |
| Settings | Preferences, notification settings, donations and privacy | Shared, SharedUI, Reminders |
| Intro | Onboarding presentation and completion callback | Shared, SharedUI |
| PreviewSupport | Repeatable sample models and in-memory containers without CloudKit | Shared, SharedUI |

Pets and Settings also declare PreviewSupport for debug previews; imports must be inside `#if DEBUG`. The ModuleTests package contains public API consumer tests and has no production product.

The app target owns startup, onboarding completion state, tabs, URL parsing, navigation coordination, production persistence configuration, App Intents registration, App Shortcuts updates, and Spotlight. Feature packages cannot import one another, the app, AppIntents, or CoreSpotlight. The app composes Settings' pet-management destination with a closure that returns the Pets screen. The app shares the notification service, persistence container, and PetCare service. Each PetReminderWindow owns its navigation coordinator, calendar manager, and location service. The app-owned navigation dependency is an App Intent inbox that forwards to the key window and retains requests until a window connects.

## Boundary contracts

- IntroView receives an onContinue callback. The app owns the existing helloSeen preference and the transition to HomeManager; onboarding has no notification-service dependency.
- Feature roots expose small public initializers. Views and mutable services are main-actor isolated. Platform-service protocols allow fakes without introducing a general-purpose repository framework.
- Pet routes carry UUID identities, legacy names or Add Pet requests. Each request has a token; acknowledging an old token cannot clear a newer request. The app accepts URLs before onboarding finishes and retains them until Pets acknowledges them.
- UUID resolution queries saved data through a fresh context, then returns the corresponding model in the UI context. Saved names can change without invalidating UUID routes. Deleted identities do not resolve.
- PetCare operations use fresh contexts and return Sendable snapshots. An Intent save must not commit unfinished UI edits. Failed saves roll back; repeated meal recording preserves its original timestamp. UI refresh sessions reload saved data separately.
- SharedStrings and SharedResources provide explicit access to the Shared resource bundle. Generated asset and localization symbols remain implementation details. Default pet images live in the original resource bundle. App catalogs remain available for app-owned and system metadata localization.
- Persisted model types stay in Shared. Do not rename stored fields, move schema types, change migration stages, move the store, or alter CloudKit identifiers as an incidental modularization change.

## Multiplatform readiness

- **Portraits.** `SharedUI.PetPortrait` takes image data, pet kind, and a presentation style. UIKit decoding stays behind the view. The Pets feature owns photo selection, drag and drop, and editing state. The selected pet kind drives the fallback portrait in the editor.
- **Feeding.** `SharedUI.MealButton` takes a meal, completion state, and an action. Pets owns the layout, save errors, and the connection to `PetCare`. The widget keeps its own presentation and reuses the feeding operation through its intent.
- **Platform integration.** App shells own navigation, windows, and commands. The iPad key-window observer lives in its own app file. Keep future platform checks local to the affected integration, such as Settings links or calendar editing. Use adaptive layout for changes driven by the available space.

Before adding a platform, choose its first end-to-end flow. Use that flow to decide which packages need to support the destination, what the app shell owns, and how it reads and updates pet data. Keep persisted models and migrations in Shared.

## Checks

Run `python3 ci_scripts/check_modules.py` to validate local package paths, dependency products, imports, source ownership, cycles and debug-only preview imports. Run its regression tests with `python3 -m unittest discover -s ci_scripts -p 'test_module_boundaries.py'`. Xcode Cloud runs both checks before its build.

The shared **Pet Reminder** scheme uses **Pet Reminder.xctestplan**, which includes each package's unit tests, ModuleTests public API/resource tests, and hosted app integration tests. Run it on an iOS 27 simulator. Individual package manifests can also be opened in Xcode for isolated package testing.

Every extraction must pass its existing tests before the next proceeds. Debug and Release builds verify actor annotations, access control and resource references under both configurations. Hosted integration tests retain the shipped V4 store fixture, migration chain, Intent context isolation, reminder editing, navigation and Spotlight behavior.

## Release validation

Before release, verify Siri and Spotlight on a signed device, denied notification/calendar/location permissions, localized content, and layouts/previews on iPhone and iPad. Upgrade two iCloud devices with existing pets and verify UUID convergence and saved references after synchronization. Simulator tests cannot establish real CloudKit convergence or device Siri behavior.

No widget, storage migration, new third-party dependency, or user-facing feature is included in this extraction.

## Implementation validation — 9 October 2026

- Baseline: 45 hosted app tests passed before extraction.
- Final shared test plan: 68 Swift tests passed across eight test targets on the iPhone 18 Pro iOS 27.0 simulator.
- Dependency checker and three checker regression tests passed; CI shell syntax and Git whitespace checks passed.
- Debug and Release builds passed for generic iOS Simulator destinations.
- Persisted `@Model` declarations and both migration plans were compared with the baseline and matched exactly. The shipped V4 store migration test passed.
- Simulator smoke checks used isolated in-memory sample data: Pets, Events, VetFinder, Settings → pet management → editing, legacy pet-name links, and Add Pet routes rendered successfully. No sample pet was created or edited during the smoke checks.
- Signed-device Siri/Spotlight, physical-device permission and layout checks, and two-device CloudKit convergence remain release validation.

### Intro extraction

- Moved onboarding into the separate Intro package; only IntroView and its completion callback are public. The app retains the existing persisted completion flag. Five localized previews use the Shared bundle without a notification manager.
- App Intents and Spotlight remain app-owned.
- The full 68-test simulator plan passed, including a public consumer composing IntroView without @testable. Release simulator build, dependency checks, four boundary-checker regression tests, and whitespace checks passed.

## Home and Lock Screen widgets — 27.3

The app embeds `PetReminderWidgets`, a WidgetKit extension with two widgets:

- **Pet's daily care**: choose a pet; small and medium Home Screen cards and circular, rectangular, and inline Lock Screen accessories.
- **Your little crew**: small, medium, and large Home Screen feeding overviews. Medium and large rows open the corresponding pet.

`WidgetSupport/WidgetSnapshot.swift` belongs to both targets and contains only Foundation value types and atomic snapshot-file storage. The shared `ToggleWidgetMealIntent` uses the app process for Home Screen meal-button actions; the app registers a `WidgetFeedingAction` dependency backed by its existing PetCare service. The extension does not open SwiftData or CloudKit. The app's `PetWidgetPublisher` reads a fresh saved context, downsamples portraits, and exports a read-only snapshot to `group.com.egesucu.Pet-Reminder`. Save, foreground, and successful CloudKit import notifications coalesce exports. Production persistence explicitly uses `groupContainer: .none` to retain the existing store location after adding the App Group entitlement.

Timelines include a next-local-midnight entry that resets yesterday's meal completions, with calendar-based date arithmetic for daylight-saving changes. When the shared snapshot is unavailable, WidgetKit is asked to retry after five minutes. App activation also requests a timeline reload after publishing, even when the snapshot on disk already matches, so widgets can recover from a cached empty entry.

Widget taps use `petreminder://pet/<UUID>` and the existing identity-based navigation. Morning and evening App Intent toggles update or undo the selected meal in the background. WidgetKit can flip the checkmark immediately while the intent saves. The refreshed timeline reconciles the display with saved data. The intent includes the meal state from that timeline so retrying the same action cannot undo the first update. Undo clears the selected meal and its timestamp across today's synced duplicate records, preserving the other meal. An action from another day refreshes the widget without changing a meal. Deleted pets, changed schedules, and failed saves also reconcile the saved snapshot; failures propagate from the intent after reconciliation. Widgets show the last exported state. Changes synchronized while the app is not running appear after the app next refreshes its snapshot.

The extension includes six-language localization, removable container backgrounds, accented image rendering, dark appearance, VoiceOver meal status, and gallery previews. Portraits prefer the saved photo, then dog, cat, fish, or bird symbols; other or unknown species use a heart. The app exports the species in its snapshot; older snapshots without a species remain readable. General care uses a single heart, and meals retain sun, moon, and checkmark symbols. Before a signed-device release, enable the same App Group for the app and extension identifiers and refresh their provisioning profiles. Verify pet selection, portraits, feeding changes, rename/deletion, midnight rollover, Lock Screen accessories, and tinted appearance on device. Simulator builds alone do not validate provisioning or system refresh budgets.
