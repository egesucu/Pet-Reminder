//
//  PreviewSampleData.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 27.06.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

import SwiftData
import SwiftUI

/**
 Preview sample data.
 */
actor PreviewSampleData {
    @MainActor
    static var container: ModelContainer = {
        let schema = Schema([Pet.self, Vaccine.self, Feed.self])
        let configuration = ModelConfiguration(inMemory: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let sampleData: [any PersistentModel] = [
                Pet.demo, Vaccine.demo, Feed.demo
            ]
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        } catch let error {
            print(error)
        }

        return container
    }()

    @MainActor
        static var previewPet: Pet = {
            let container = PreviewSampleData.container
            container.mainContext.insert(Pet.demo)

            return Pet.demo
        }()
}
