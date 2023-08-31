//
//  FeedListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import CoreData
import OSLog

struct FeedListView: View {

    @Environment(\.managedObjectContext) var viewContext

    @Binding var pet: Pet?

    @State private var viewModel = FeedListViewModel()

    let feedback = UINotificationFeedbackGenerator()

    var todaysFeeds: [Feed] {
        if let pet,
           let feedSet = pet.feeds,
           let feeds = feedSet.allObjects as? [Feed] {
            return feeds.filter { feed in
                Calendar.current.isDateInToday(feed.feedDate ?? .now)
            }
        }
        return []
    }

    var body: some View {
        HStack(spacing: 30) {
            if let pet {
                switch pet.selection {
                case .morning:
                    MorningCheckboxView(morningOn: $viewModel.morningOn)
                        .onChange(of: viewModel.morningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Morning Changed, new value: \(viewModel.morningOn), pet: \(pet.wrappedName)")
                            feedback.notificationOccurred(.success)
                            viewModel.updateFeed(pet: pet, feeds: todaysFeeds, type: .morning, viewContext: viewContext)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Morning Tapped, pet: \(pet.wrappedName)")
                            viewModel.morningOn.toggle()
                        }
                case .evening:
                    EveningCheckboxView(eveningOn: $viewModel.eveningOn)
                        .onChange(of: viewModel.eveningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Evening Changed, new value: \(viewModel.eveningOn), pet: \(pet.wrappedName)")
                            feedback.notificationOccurred(.success)
                            viewModel.updateFeed(pet: pet, feeds: todaysFeeds, type: .evening, viewContext: viewContext)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Evening Tapped, pet: \(pet.wrappedName)")
                            viewModel.eveningOn.toggle()
                        }
                case .both:
                    MorningCheckboxView(morningOn: $viewModel.morningOn)
                        .onChange(of: viewModel.morningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Morning Changed, new value: \(viewModel.morningOn), pet: \(pet.wrappedName)")
                            feedback.notificationOccurred(.success)
                            viewModel.updateFeed(pet: pet, feeds: todaysFeeds, type: .morning, viewContext: viewContext)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Morning Tapped, pet: \(pet.wrappedName)")
                            viewModel.morningOn.toggle()
                        }
                    EveningCheckboxView(eveningOn: $viewModel.eveningOn)
                        .onChange(of: viewModel.eveningOn, {
                            Logger
                                .viewCycle
                                .info("PR: Evening Changed, new value: \(viewModel.eveningOn), pet: \(pet.wrappedName)")
                            feedback.notificationOccurred(.success)
                            viewModel.updateFeed(pet: pet, feeds: todaysFeeds, type: .evening, viewContext: viewContext)
                        })
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Evening Tapped, pet: \(pet.wrappedName)")
                            viewModel.eveningOn.toggle()
                        }
                }
            }

        }
        .task {
            await viewModel.getLatestFeed(pet: pet)
        }
        .onChange(of: pet) {
            Task {
                await viewModel.getLatestFeed(pet: pet)
            }
        }
    }
}

#Preview {
    let preview = PersistenceController.preview.container.viewContext
    return FeedListView(pet: .constant(Pet(context: preview)))
        .environment(\.managedObjectContext, preview)
}
