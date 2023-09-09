//
//  NewAddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import OSLog

struct NewAddPetView: View {

    @State private var manager = AddPetViewModel()
    @State private var position = 0
    @State private var step: SetupSteps = .name
    @State private var feedTime: FeedTimeSelection = .both
    @State private var nameIsFilledCorrectly = false
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.managedObjectContext)
    private var viewContext

    var body: some View {
        VStack {
            GeometryReader(content: { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        LazyHStack {
                            PetNameTextField(name: $manager.name, nameIsFilledCorrectly: $nameIsFilledCorrectly)
                                .scrollTargetLayout()
                                .id(SetupSteps.name)
                                .padding(.all)
                                .frame(width: geometry.size.width)

                            PetBirthdayView(birthday: $manager.birthday)
                                .scrollTargetLayout()
                                .padding(.all)
                                .id(SetupSteps.birthday)
                                .frame(width: geometry.size.width)
                            PetImageView(selectedImageData: $manager.selectedImageData, selectedPage: $step)
                                .scrollTargetLayout()
                                .padding(.all)
                                .id(SetupSteps.photo)
                                .frame(width: geometry.size.width)
                            NotificationSelectView(dayType: $feedTime)
                                .scrollTargetLayout()
                                .padding(.all)
                                .id(SetupSteps.feedSelection)
                                .frame(width: geometry.size.width)
                            PetNotificationSelectionView(
                                dayType: $feedTime,
                                morningFeed: $manager.morningFeed,
                                eveningFeed: $manager.eveningFeed
                            )
                                .scrollTargetLayout()
                                .padding(.all)
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
            Logger.viewCycle.info("Page Value: \(step.text)")
        }
    }
// swiftlint: disable function_body_length
    private func actionView(
        proxy: ScrollViewProxy
    ) -> some View {
        HStack {
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
            } // swiftlint: enable function_body_length
            .buttonStyle(.bordered)
            .tint(step == .name ? .red : Color(uiColor: .label))
            Spacer()
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
                            await manager
                                .savePet(
                                    modelContext: viewContext) {
                                        dismiss()
                                    }
                        }
                    }
                }
            }
            .buttonStyle(.bordered)
            .tint(step == .feedTime ? .green : Color(uiColor: .label))
            .disabled(!nameIsFilledCorrectly)
        }
        .padding(50)
    }
}

#Preview {
    NewAddPetView()
}
