//
//  ModelContainerView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftData
import SwiftUI

struct ModelContainerPreview<Content: View>: View {

  // MARK: Lifecycle

  init(@ViewBuilder content: @escaping () -> Content, modelContainer: @escaping () throws -> ModelContainer) {
    self.content = content
    do {
      container = try MainActor.assumeIsolated(modelContainer)
    } catch {
      fatalError("Failed to create the model container: \(error.localizedDescription)")
    }
  }

  init(_ modelContainer: @escaping () throws -> ModelContainer, @ViewBuilder content: @escaping () -> Content) {
    self.init(content: content, modelContainer: modelContainer)
  }

  // MARK: Internal

  var content: () -> Content
  let container: ModelContainer

  var body: some View {
    content()
      .modelContainer(container)
  }
}
