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

  @MainActor static var container: ModelContainer = try! inMemoryContainer()

  static var inMemoryContainer: () throws -> ModelContainer = {
    let schema = Schema([Pet.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let sampleData: [any PersistentModel] = Pet().previews
    Task { @MainActor in
      for sampleDatum in sampleData {
        container.mainContext.insert(sampleDatum)
      }
    }
    return container
  }
}
