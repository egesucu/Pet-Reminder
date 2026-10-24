# Pet Reminder

![Swift 6.4](https://img.shields.io/badge/Swift-6.4-F05138?logo=swift&logoColor=white)
![Xcode 27](https://img.shields.io/badge/Xcode-27-147EFB?logo=xcode&logoColor=white)
![iOS 27+](https://img.shields.io/badge/iOS-27%2B-000000?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift&logoColor=white)
[![MIT License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Pet Reminder is an iPhone and iPad app that helps you manage your pets' daily care. Keep pet profiles, track meals and vaccinations, plan events, and find nearby veterinarians in one place.

The SwiftUI app composes feature and service modules implemented as local Swift packages. The app target owns startup, navigation, persistence configuration, and system integrations.

## Features

- **Pet profiles:** Add multiple pets with a name, photo, birthday, breed, and animal type.
- **Feeding reminders:** Choose morning, evening, or both feeding schedules and configure recurring local notifications. Birthday notifications help you remember your pets' special days.
- **Feeding history:** Record completed meals and review the last seven days with a chart, completion rate, feed count, and daily streak.
- **Vaccination records:** Save vaccine names and dates for each pet.
- **Calendar events:** Create pet-related events, browse today's and upcoming events, and add calendar alarms through Apple's EventKit integration.
- **Vet finder:** Search for nearby veterinarians on a map and open directions in a supported maps app.
- **Data persistence:** Store pet data with SwiftData, with CloudKit integration configured for iCloud sync.
- **Spotlight:** Search saved pets by name, animal type, or breed and open their details.
- **Siri and Shortcuts:** Find pets, check today's feeding status, record a meal, and open a pet's details with App Intents.
- **Localization:** String catalogs support localized app text and reminders.

## Built with

The app uses SwiftUI and Observation for its interface and state, SwiftData for persistence and schema migrations, UserNotifications for reminders, EventKit for calendar integration, MapKit and Core Location for vet search, and Swift Charts for feeding insights.

## Modules and architecture

Packages live under [`Pet Reminder/Packages`](Pet%20Reminder/Packages). Each production package has one library target with the same name as the package. Dependencies use explicit local paths; there are no third-party packages.

| Package | Responsibility | Library dependencies |
| --- | --- | --- |
| `Shared` | SwiftData models, schema migrations, common values, localization, and shared assets | None |
| `SharedUI` | Reusable SwiftUI views, modifiers, and image/presentation helpers | `Shared` |
| `PetCare` | Feeding operations, saved-data snapshots, isolated operation contexts, and UI refresh sessions | `Shared` |
| `Reminders` | Feeding and birthday notifications, scheduling, and notification authorization | `Shared` |
| `Pets` | Pet lists, creation, editing, details, feeding history, and vaccination screens | `Shared`, `SharedUI`, `PetCare`, `Reminders` |
| `Events` | Calendar access, event models, agenda rules, and event screens | `Shared`, `SharedUI` |
| `VetFinder` | Location services, nearby vet search, maps, and directions | `Shared`, `SharedUI` |
| `Settings` | Preferences, notification settings, donations, and privacy screens | `Shared`, `SharedUI`, `Reminders` |
| `Intro` | Onboarding UI and a completion callback | `Shared`, `SharedUI` |
| `PreviewSupport` | Repeatable sample data and in-memory preview containers without CloudKit | `Shared`, `SharedUI` |
| `ModuleTests` | Public API and resource consumer tests; no production library | All libraries above |

`Pets` and `Settings` also declare `PreviewSupport` for previews; its imports must stay inside `#if DEBUG`. Package unit tests live in `Tests/<ModuleName>Tests` where present, and `ModuleTests/Tests/ModuleAPITests` exercises public APIs without `@testable` imports.

The app connects these modules in `PetReminderApp` and `HomeManager`:

- `PetReminderApp` creates the production model container and notification, calendar, location, and pet-care services, injects them into the view tree, and switches from onboarding to the home tabs.
- `HomeManager` composes the Pets, Events, Settings, and VetFinder screens. The app supplies Settings' pet-management destination as a closure, keeping Settings independent of Pets.
- `AppNavigationCoordinator` handles incoming URLs and pet routes, including requests received before onboarding completes. App Intents, App Shortcuts, and Spotlight remain in the app target and use `PetCare` for feeding operations.

Feature packages depend on shared libraries and services rather than importing other features or the app. Persisted models and migration definitions remain in `Shared`; production store and CloudKit configuration remain app-owned. Shared strings and assets are accessed through `SharedStrings` and `SharedResources`.

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed ownership and integration contracts.

## Getting started

The current app and app test targets require **iOS 27.0 or later**. All local packages also require iOS 27.0 and use Swift tools version 6.4. Use an Xcode installation with an iOS 27 SDK and support for Swift tools 6.4 or later.

1. Clone this repository and open `Pet Reminder.xcodeproj` in Xcode.
2. Allow Xcode to resolve the local packages under `Pet Reminder/Packages`.
3. Select the **Pet Reminder** scheme and a compatible iPhone or iPad simulator or device.
4. For device builds, choose your development team under **Signing & Capabilities**. If using your own app identifier, configure a matching iCloud container and update the app's entitlements. The checked-in container is `iCloud.com.egesucu.Pet-Reminder`.
5. Build and run with **⌘R**.

Enable notifications to receive feeding and birthday reminders, calendar access to manage events, and location access to use the nearby vet finder.

## App Intents

In Shortcuts, search for **Pet Reminder** to find these actions:

| Action | Parameters | Result |
| --- | --- | --- |
| Find Pets | Optional name search | Matching pets, or all pets, sorted by name |
| Get Today's Feeding Status | Pet | Local day, feeding schedule, morning/evening completion flags and timestamps |
| Mark Meal Fed | Pet and Morning or Evening | Updated feeding status |
| Open Pet | Pet | Opens that pet's detail screen |

App Shortcuts provide phrases such as “Open Luna in Pet Reminder,” “Check Luna's feeding in Pet Reminder,” and “Record a meal in Pet Reminder.” The system asks for missing parameters. Actions require device authentication. Reading and recording can run in the background; opening a pet brings the app forward. Titles, dialogs, and shortcut phrases support English, Turkish, German, Spanish, French, and Italian.

Meal recording uses today's date in the device's current calendar and time zone. Only meals in the pet's configured schedule can be recorded. Repeating the action preserves completion and the original timestamp; it does not toggle or undo a meal. Saved shortcuts identify pets by a persistent UUID, so renaming a pet does not change the reference. Deleted pets must be selected again.

Schema V5 adds optional UUID storage, backfills existing pets, and assigns and saves IDs for older records imported from CloudKit before exposing them as entities. Production persistence keeps the existing store location and migration chain. Intent operations use separate contexts to protect unfinished UI edits; the feeding controls and history refresh their own session after saves and app activation.

Pet entities are also indexed in Spotlight. Search by name, animal type, or breed; the Open Pet result opens the matching UUID. Spotlight may also show feeding App Shortcuts for that pet. The app reconciles the index after successful saves, CloudKit imports, and activation, and removes deleted pets across launches. System requests can rebuild all pets or selected identities. Indexing reads saved data only and uses complete file protection; unfinished edits and screenshot samples are excluded. Feeding status stays a live query rather than indexed content.

The `PetCare` package contains `PetCareService`, `PetCareSession`, and `DailyFeeds` for reuse by the app and system integrations. No widget extension, AI experience, or App Group storage move is included. A future widget must share the actions/entities and dependencies with its extension and explicitly plan cross-process storage and timeline refresh. App Intents expose the app's capabilities to supported system experiences; they do not by themselves provide a custom AI feature.

Before release, validate Siri on a signed compatible device and test upgrading two iCloud devices with the same existing pets. Independently upgrading legacy stores can initially assign different UUIDs to the same synced record; check convergence and saved-reference behavior after CloudKit synchronization. Simulator tests do not establish this behavior.

## Repository layout

```text
Pet Reminder/
├── Features/AppIntents/     # Entities, intents, shortcuts, and Spotlight indexing
├── HomeTabs/               # Tab composition and navigation coordination
├── Utilities/              # App entry point, persistence configuration, and app resources
├── AppIcon.icon/           # Icon Composer app icon
├── Preview Content/        # App preview assets
└── Packages/
    ├── Shared/
    ├── SharedUI/
    ├── PetCare/
    ├── Reminders/
    ├── Pets/
    ├── Events/
    ├── VetFinder/
    ├── Settings/
    ├── Intro/
    ├── PreviewSupport/
    └── ModuleTests/
Pet Reminder.xcodeproj/     # Xcode project and workspace
Pet Reminder.xctestplan     # Shared app-hosted test plan
Pet ReminderTests/          # App integration tests and migration fixtures
AppStore/                  # Store descriptions, release notes, screenshots, and promotional assets
ci_scripts/                # Repository checks and Xcode Cloud lifecycle scripts
ARCHITECTURE.md             # Module boundaries and integration contracts
TESTING.md                 # Simulator/device test commands and test-plan maintenance
```

Each library package contains `Package.swift` and `Sources/<ModuleName>/`, plus `Tests/<ModuleName>Tests/` where it has unit tests. `ModuleTests` contains only its manifest and public API tests.

## Testing and contributing

Select the **Pet Reminder** scheme and **Pet Reminder** test plan in Xcode, choose a compatible simulator or signed device, and run **⌘U**. The checked-in plan selects one app-hosted target, `Pet ReminderTests`, which includes package unit tests and public API/resource checks alongside integration tests for data integrity and migrations, reminder editing, navigation, App Intents, and Spotlight.

For focused simulator testing, open an individual package's `Package.swift` in Xcode and run its test target where available. [TESTING.md](TESTING.md) describes the full-suite app-hosted setup and command-line simulator/device examples. After changing test membership, verify in Xcode that the intended package suites are included in the run.

Repository checks:

```sh
# Validate package dependencies, imports, source ownership, and debug-only previews.
python3 ci_scripts/check_modules.py

# Verify the main test plan includes all package test sources without exclusions.
python3 ci_scripts/check_test_plan.py

# Run regression tests for the module-boundary and test-plan checkers.
python3 -m unittest discover -s ci_scripts -p 'test_*.py'

# Check localization completeness and format arguments.
python3 ci_scripts/check_localizations.py
```

Xcode Cloud invokes the module checker, test-plan checker, and checker regression tests before builds. The test-plan checker reads target membership directly from `Pet Reminder.xcodeproj/project.xcproj`, including folder exclusions.

Bug reports and pull requests are welcome. Include steps to reproduce a bug and describe how you validated a change. Follow the [Code of Conduct](CODE_OF_CONDUCT.md), and use the [Security Policy](SECURITY.md) to report vulnerabilities.

## License

Pet Reminder is available under the [MIT License](LICENSE).
