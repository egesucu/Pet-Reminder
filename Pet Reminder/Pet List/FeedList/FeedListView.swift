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
                            viewModel.updateFeed(pet: pet, type: .morning, viewContext: viewContext)
                        })
                        .sensoryFeedback(.selection, trigger: viewModel.morningOn)
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
                            viewModel.updateFeed(pet: pet, type: .evening, viewContext: viewContext)
                        })
                        .sensoryFeedback(.selection, trigger: viewModel.eveningOn)
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
                            viewModel.updateFeed(pet: pet, type: .morning, viewContext: viewContext)
                        })
                        .sensoryFeedback(.selection, trigger: viewModel.morningOn)
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
                            viewModel.updateFeed(pet: pet, type: .evening, viewContext: viewContext)
                        })
                        .sensoryFeedback(.selection, trigger: viewModel.eveningOn)
                        .onTapGesture {
                            Logger
                                .viewCycle
                                .info("PR: Evening Tapped, pet: \(pet.wrappedName)")
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
}

#Preview {
    let preview = PersistenceController.preview.container.viewContext
    return FeedListView(pet: .constant(Pet(context: preview)))
        .environment(\.managedObjectContext, preview)
}
