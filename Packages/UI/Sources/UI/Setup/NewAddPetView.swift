//
//  NewAddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import SwiftData
import SharedModels

public struct NewAddPetView: View {

    @State private var viewModel: AddPetViewModel

    @State private var position = 0
    @State private var step: SetupSteps = .name
    @State private var feedTime: FeedSelection = .both
    @State private var nameIsFilledCorrectly = false
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.modelContext)
    private var modelContext

    init(
        viewModel: AddPetViewModel
    ) {
        _viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            GeometryReader(content: { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        LazyHStack {
                            PetNameTextField(name: $viewModel.name, nameIsFilledCorrectly: $nameIsFilledCorrectly)
                                .scrollTargetLayout()
                                .id(SetupSteps.name)
                                .padding()
                                .frame(width: geometry.size.width)

                            PetBirthdayView(birthday: $viewModel.birthday)
                                .scrollTargetLayout()
                                .padding()
                                .id(SetupSteps.birthday)
                                .frame(width: geometry.size.width)
                            PetImageView(selectedImageData: $viewModel.selectedImageData, selectedPage: $step)
                                .scrollTargetLayout()
                                .padding()
                                .id(SetupSteps.photo)
                                .frame(width: geometry.size.width)
                            NotificationSelectView(dayType: $feedTime)
                                .scrollTargetLayout()
                                .padding()
                                .id(SetupSteps.feedSelection)
                                .frame(width: geometry.size.width)
                            PetNotificationSelectionView(
                                dayType: $feedTime,
                                morningFeed: $viewModel.morningFeed,
                                eveningFeed: $viewModel.eveningFeed
                            )
                                .scrollTargetLayout()
                                .padding()
                                .id(SetupSteps.feedTime)
                                .frame(width: geometry.size.width)
                        }

                    }
                    .scrollDisabled(true)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.never)

                    Spacer()
                    actionView(proxy: proxy)
                }
            })

        }
        .onChange(of: step) {
            Logger.pets.info("Page Value: \(step.text)")
        }
    }

    private func actionView(
        proxy: ScrollViewProxy
    ) -> some View {
        HStack {
            previousButton(proxy: proxy)
            .buttonStyle(.bordered)
            .tint(step == .name ? .red : ESColor.label)
            Spacer()
            nextButton(proxy: proxy)
        }
        .padding(50)
    }

    private func previousButton(proxy: ScrollViewProxy) -> some View {
        Button(step != .name ? "Back" : "Cancel") {
            withAnimation {
                switch step {
                case .name:
                    dismiss()
                case .birthday:
                    step = .name
                    proxy.scrollTo(SetupSteps.name)
                case .photo:
                    step = .birthday
                    proxy.scrollTo(SetupSteps.birthday)
                case .feedSelection:
                    step = .photo
                    proxy.scrollTo(SetupSteps.photo)
                case .feedTime:
                    step = .feedSelection
                    proxy.scrollTo(SetupSteps.feedSelection)
                }
            }
        }
    }

    private func nextButton(proxy: ScrollViewProxy) -> some View {
        Button(step != .feedTime ? "Next" : "Save") {
            withAnimation {
                switch step {
                case .name:
                    step = .birthday
                    proxy.scrollTo(SetupSteps.birthday)
                case .birthday:
                    step = .photo
                    proxy.scrollTo(SetupSteps.photo)
                case .photo:
                    step = .feedSelection
                    proxy.scrollTo(SetupSteps.feedSelection)
                case .feedSelection:
                    step = .feedTime
                    proxy.scrollTo(SetupSteps.feedTime)
                case .feedTime:
                    Task {
                        let pet = await viewModel.savePet()
                        modelContext.insert(pet)
                        dismiss()
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .tint(step == .feedTime ? .green : ESColor.label)
        .disabled(!nameIsFilledCorrectly)
    }
}

#Preview {
    NewAddPetView(
        viewModel: .init(notificationManager: .init())
    )
}
