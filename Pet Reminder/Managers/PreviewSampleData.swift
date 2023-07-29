//
//  PreviewSampleData.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 29.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftData

actor PreviewSampleData {
    @MainActor
    static var container: ModelContainer = {
        let schema = Schema([Pet.self, Feed.self, Vaccine.self])
        let configuration = ModelConfiguration(inMemory: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = [
            Pet.demo, Feed.demo, Vaccine.demo
        ]
        sampleData.forEach {
            container.mainContext.insert($0)
        }
        return container
    }()

    @MainActor
    static var previewPet: Pet = {
        let container = PreviewSampleData.container
        let pet = Pet.demo
        container.mainContext.insert(pet)
        return pet
    }()
}
