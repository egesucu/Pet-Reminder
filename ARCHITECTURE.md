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

The app target owns startup, onboarding completion state, tabs, URL parsing, navigation coordination, production persistence configuration, App Intents registration, App Shortcuts updates, and Spotlight. Feature packages cannot import one another, the app, AppIntents, or CoreSpotlight. The app composes Settings' pet-management destination with a closure that returns the Pets screen. Production notification, calendar and location services are created at startup and injected into the feature tree.

## Boundary contracts

- IntroView receives an onContinue callback. The app owns the existing helloSeen preference and the transition to HomeManager; onboarding has no notification-service dependency.
- Feature roots expose small public initializers. Views and mutable services are main-actor isolated. Platform-service protocols allow fakes without introducing a general-purpose repository framework.
- Pet routes carry UUID identities, legacy names or Add Pet requests. Each request has a token; acknowledging an old token cannot clear a newer request. The app accepts URLs before onboarding finishes and retains them until Pets acknowledges them.
- UUID resolution queries saved data through a fresh context, then returns the corresponding model in the UI context. Saved names can change without invalidating UUID routes. Deleted identities do not resolve.
- PetCare operations use fresh contexts and return Sendable snapshots. An Intent save must not commit unfinished UI edits. Failed saves roll back; repeated meal recording preserves its original timestamp. UI refresh sessions reload saved data separately.
- SharedStrings and SharedResources provide explicit access to the Shared resource bundle. Generated asset and localization symbols remain implementation details. Default pet images live in the original resource bundle. App catalogs remain available for app-owned and system metadata localization.
- Persisted model types stay in Shared. Do not rename stored fields, move schema types, change migration stages, move the store, or alter CloudKit identifiers as an incidental modularization change.

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
