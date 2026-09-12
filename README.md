# Pet Reminder

![Swift 6.4](https://img.shields.io/badge/Swift-6.4-F05138?logo=swift&logoColor=white)
![Xcode 27](https://img.shields.io/badge/Xcode-27-147EFB?logo=xcode&logoColor=white)
![iOS 27+](https://img.shields.io/badge/iOS-27%2B-000000?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift&logoColor=white)
[![MIT License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Pet Reminder is an iPhone and iPad app that helps you manage your pets' daily care. Keep pet profiles, track meals and vaccinations, plan events, and find nearby veterinarians in one place.

This repository contains the app's Swift source code, with an interface built using SwiftUI.

## Features

- **Pet profiles:** Add multiple pets with a name, photo, birthday, breed, and animal type.
- **Feeding reminders:** Choose morning, evening, or both feeding schedules and configure recurring local notifications. Birthday notifications help you remember your pets' special days.
- **Feeding history:** Record completed meals and review the last seven days with a chart, completion rate, feed count, and daily streak.
- **Vaccination records:** Save vaccine names and dates for each pet.
- **Calendar events:** Create pet-related events, browse today's and upcoming events, and add calendar alarms through Apple's EventKit integration.
- **Vet finder:** Search for nearby veterinarians on a map and open directions in a supported maps app.
- **Data persistence:** Store pet data with SwiftData, with CloudKit integration configured for iCloud sync.
- **Localization:** String catalogs support localized app text and reminders.

## Built with

The app uses SwiftUI and Observation for its interface and state, SwiftData for persistence and schema migrations, UserNotifications for reminders, EventKit for calendar integration, MapKit and Core Location for vet search, and Swift Charts for feeding insights.

A local Swift package, `Shared`, contains reusable models, views, extensions, and resources. It has no external package dependencies.

## Getting started

The current app and app test targets require **iOS 27.0 or later**. The `Shared` package declares iOS 26.0 as its minimum and uses Swift tools version 6.4. Use an Xcode installation with an iOS 27 SDK and support for Swift tools 6.4 or later.

1. Clone this repository and open `Pet Reminder.xcodeproj` in Xcode.
2. Allow Xcode to resolve the local `Shared` package.
3. Select the **Pet Reminder** scheme and a compatible iPhone or iPad simulator or device.
4. For device builds, choose your development team under **Signing & Capabilities**. If using your own app identifier, configure a matching iCloud container and update the app's entitlements. The checked-in container is `iCloud.com.egesucu.Pet-Reminder`.
5. Build and run with **⌘R**.

Enable notifications to receive feeding and birthday reminders, calendar access to manage events, and location access to use the nearby vet finder.

## Repository layout

| Path | Contents |
| --- | --- |
| `Pet Reminder/Features/` | Pet management, feeding and vaccination history, events, vet search, onboarding, and settings |
| `Pet Reminder/HomeTabs/` | Tab navigation and deep-link handling |
| `Pet Reminder/Utilities/` | App entry point, persistence helpers, configuration, and app resources |
| `Pet Reminder/Packages/Shared/` | Shared Swift package and its unit tests |
| `Pet ReminderTests/` | App tests for notifications, calendar alarms, feeding records, pet data integrity, and vet services |
| `AppStore/` | Store descriptions, release notes, screenshots, and promotional assets |
| `ci_scripts/` | Xcode Cloud lifecycle scripts |

## Testing and contributing

Run the app test target in Xcode with **⌘U** on a compatible simulator. The `Shared` package also includes tests for models, extensions, and string identifiers; open its `Package.swift` in Xcode to run those tests with an iOS simulator destination.

Bug reports and pull requests are welcome. Include steps to reproduce a bug and describe how you validated a change. Follow the [Code of Conduct](CODE_OF_CONDUCT.md), and use the [Security Policy](SECURITY.md) to report vulnerabilities.

## License

Pet Reminder is available under the [MIT License](LICENSE).
