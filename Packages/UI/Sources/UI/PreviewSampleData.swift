//
//  PreviewSampleData.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftData
import SwiftUI
import SharedModels

actor PreviewSampleData {
// swiftlint: disable force_try
    @MainActor
    static var container: ModelContainer = {
        return try! inMemoryContainer()
    }()

    static var inMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([Pet.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [Pet] = Pet.previews
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
    }
} // swiftlint: enable force_try
