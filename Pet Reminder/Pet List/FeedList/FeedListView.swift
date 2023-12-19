//
//  FeedListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import OSLog
import SwiftData
import SwiftUI

struct FeedListView: View {

  // MARK: Internal

  @Binding var pet: Pet?

  var body: some View {
    HStack(spacing: 30) {
      if let pet {
        switch pet.selection {
        case .morning:
          MorningCheckboxView(morningOn: $viewModel.morningOn)
            .onChange(of: viewModel.morningOn) {
              Logger
                .feed
                .info("PR: Morning Changed, new value: \(viewModel.morningOn), pet: \(pet.name)")
              viewModel.updateFeed(pet: pet, type: .morning)
            }
            .sensoryFeedback(.selection, trigger: viewModel.morningOn)
            .onTapGesture {
              Logger
                .feed
                .info("PR: Morning Tapped, pet: \(pet.name)")
              viewModel.morningOn.toggle()
            }
        case .evening:
          EveningCheckboxView(eveningOn: $viewModel.eveningOn)
            .onChange(of: viewModel.eveningOn) {
              Logger
                .feed
                .info("PR: Evening Changed, new value: \(viewModel.eveningOn), pet: \(pet.name)")
              viewModel.updateFeed(pet: pet, type: .evening)
            }
            .sensoryFeedback(.selection, trigger: viewModel.eveningOn)
            .onTapGesture {
              Logger
                .feed
                .info("PR: Evening Tapped, pet: \(pet.name)")
              viewModel.eveningOn.toggle()
            }
        case .both:
          MorningCheckboxView(morningOn: $viewModel.morningOn)
            .onChange(of: viewModel.morningOn) {
              Logger
                .feed
                .info("PR: Morning Changed, new value: \(viewModel.morningOn), pet: \(pet.name)")
              viewModel.updateFeed(pet: pet, type: .morning)
            }
            .sensoryFeedback(.selection, trigger: viewModel.morningOn)
            .onTapGesture {
              Logger
                .feed
                .info("PR: Morning Tapped, pet: \(pet.name)")
              viewModel.morningOn.toggle()
            }
          EveningCheckboxView(eveningOn: $viewModel.eveningOn)
            .onChange(of: viewModel.eveningOn) {
              Logger
                .feed
                .info("PR: Evening Changed, new value: \(viewModel.eveningOn), pet: \(pet.name)")
              viewModel.updateFeed(pet: pet, type: .evening)
            }
            .sensoryFeedback(.selection, trigger: viewModel.eveningOn)
            .onTapGesture {
              Logger
                .feed
                .info("PR: Evening Tapped, pet: \(pet.name)")
              viewModel.eveningOn.toggle()
            }
        }
      }
    }
    .task(getFeeds)
    .onChange(of: pet) {
      Task {
        await getFeeds()
      }
    }
  }

  @Sendable
  func getFeeds() async {
    await viewModel.getLatestFeed(pet: pet)
  }

  // MARK: Private

  @State private var viewModel = FeedListViewModel()

}

#Preview {
  FeedListView(pet: .constant(Pet()))
    .modelContainer(PreviewSampleData.container)
}
