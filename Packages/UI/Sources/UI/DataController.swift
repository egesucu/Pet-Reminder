//
//  DataController.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftData
import SwiftUI
import SharedModels

@MainActor
public class DataController {
    public static let previewContainer: ModelContainer = {
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
}
