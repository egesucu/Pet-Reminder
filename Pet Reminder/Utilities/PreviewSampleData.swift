//
//  PreviewSampleData.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftData
import SwiftUI

actor PreviewSampleData {
    
    @MainActor
        static var container: ModelContainer {
            do {
                return try inMemoryContainer()
            } catch {
                print("Failed to initialize ModelContainer: \(error)")
                fatalError()
            }
        }

    @MainActor
    static func inMemoryContainer() throws -> ModelContainer {
        let schema = Schema([Pet.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let sampleData: [any PersistentModel & Sendable] = Pet().previews
            Task { @MainActor in
                for model in sampleData {
                    container.mainContext.insert(model)
                }
            }
            return container
        } catch {
            throw error
        }
    }
}
