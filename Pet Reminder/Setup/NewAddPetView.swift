//
//  NewAddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct NewAddPetView: View {

    @State private var manager = AddPetViewModel()
    @State private var position = 0
    @State private var step: SetupSteps = .name
    @State private var feedTime: FeedTimeSelection = .both
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.managedObjectContext)
    private var viewContext

    var body: some View {
        VStack {
            PageView(
                selectedPage: $step,
                name: $manager.name,
                birthday: $manager.birthday,
                selectedImageData: $manager.selectedImageData,
                feedTime: $feedTime,
                morningFeed: $manager.morningFeed,
                eveningFeed: $manager.eveningFeed
            )
            Spacer()
            actionView
        }
    }

    private var actionView: some View {
        HStack {
            Button(step != .name ? "Back" : "Cancel") {
                withAnimation {
                    switch step {
                    case .name:
                        dismiss()
                    case .birthday:
                        step = .name
                    case .photo:
                        step = .birthday
                    case .feedSelection:
                        step = .photo
                    case .feedTime:
                        step = .feedSelection
                    }
                }
            }
            .buttonStyle(.bordered)
            .tint(step == .name ? .red : .black)
            Spacer()
            Button(step != .feedTime ? "Next" : "Save") {
                withAnimation {
                    switch step {
                    case .name:
                        step = .birthday
                    case .birthday:
                        step = .photo
                    case .photo:
                        step = .feedSelection
                    case .feedSelection:
                        step = .feedTime
                    case .feedTime:
                        manager
                            .savePet(
                                modelContext: viewContext) {
                                    dismiss()
                                }
                    }
                }
            }
            .buttonStyle(.bordered)
            .tint(step == .feedTime ? .green : .black)
            .disabled(manager.name.isEmpty)
        }
        .padding(50)
    }
}

#Preview {
    NewAddPetView()
}

struct PageView: View {

    @Binding var selectedPage: SetupSteps
    @Binding var name: String
    @Binding var birthday: Date
    @Binding var selectedImageData: Data?
    @Binding var feedTime: FeedTimeSelection
    @Binding var morningFeed: Date
    @Binding var eveningFeed: Date

    var body: some View {
        TabView(selection: $selectedPage) {
            PetNameTextField(name: $name)
                .tag(SetupSteps.name)
                .padding(.all)
            PetBirthdayView(birthday: $birthday)
                .padding(.all)
                .tag(SetupSteps.birthday)
            PetImageView(selectedImageData: $selectedImageData, selectedPage: $selectedPage)
                .padding(.all)
                .tag(SetupSteps.photo)
            NotificationSelectView(dayType: $feedTime)
                .padding(.all)
                .tag(SetupSteps.feedSelection)
            PetNotificationSelectionView(dayType: $feedTime, morningFeed: $morningFeed, eveningFeed: $eveningFeed)
                .padding(.all)
                .tag(SetupSteps.feedTime)

        }
        .frame(width: UIScreen.main.bounds.width, height: 300)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
