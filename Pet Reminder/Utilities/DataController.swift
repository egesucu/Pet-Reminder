//
//  DataController.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftData
import SwiftUI
import Shared

@MainActor
class DataController {
    #if DEBUG
    /// Isolated sample data for real simulator captures; never touches the user's store.
    static func screenshotContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            let container = try ModelContainer(for: Pet.self, configurations: config)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: .now)
            let samples: [(String, String, Int, Kind)] = [
                ("Coco", "Melopsittacus undulatus", 4, .bird),
                ("Luna", "Beagle", 2, .dog),
                ("Milo", "Maine Coon", 3, .cat)
            ]
            for (name, breed, years, kind) in samples {
                let pet = Pet(
                    birthday: calendar.date(byAdding: .year, value: -years, to: today)!,
                    name: name,
                    feedSelection: .both,
                    image: kind.uiImage.jpegData(compressionQuality: 0.95),
                    breed: breed,
                    kind: kind
                )
                container.mainContext.insert(pet)
                for offset in 0..<7 {
                    let day = calendar.date(byAdding: .day, value: -offset, to: today)!
                    pet.addFeed(Feed(
                        eveningFed: offset != 0,
                        eveningFedStamp: offset == 0 ? nil : day.addingTimeInterval(18 * 3600),
                        feedDate: day,
                        morningFed: true,
                        morningFedStamp: day.addingTimeInterval(8.5 * 3600)
                    ))
                }
            }
            try container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to prepare screenshot data: \(error)")
        }
    }
    #endif

    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Pet.self, configurations: config)
            let sampleData: [Pet] = Pet.previews

            sampleData.forEach {
                container.mainContext.insert($0)
            }

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()

    static let emptyContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Pet.self, configurations: config)
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
