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
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack {
                    PageView(
                        selectedPage: $step,
                        name: $manager.name,
                        birthday: $manager.birthday,
                        selectedImageData: $manager.selectedImageData,
                        feedTime: $feedTime,
                        morningFeed: $manager.morningFeed,
                        eveningFeed: $manager.eveningFeed
                    )
                }
            }
            Spacer()
            actionView
        }
    }
    
    private var actionView: some View {
        HStack {
            Button("Back") {
                withAnimation {
                    switch step {
                    case .name:
                        break
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
            .disabled(step == .name)
            .buttonStyle(.bordered)
            Spacer()
            Button("Next") {
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
                        break
                    }
                }
            }
            .disabled(step == .feedTime)
            .buttonStyle(.bordered)
        }
        .padding(50)
    }
}

#Preview {
    NewAddPetView()
}

enum SetupSteps: Int, CaseIterable {
    var id: String {
        UUID().uuidString
    }
    
    case name, birthday, photo, feedSelection, feedTime
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
            PetImageView(selectedImageData: $selectedImageData)
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

struct NotificationSelectView: View {
    
    @Binding var dayType: FeedTimeSelection
    
    var body: some View {
        VStack {
            Text("feed_time_title")
                .font(.title2).bold()
                .padding(.vertical)
            Picker(
                selection: $dayType,
                label: Text("feed_time_title")
            ) {
                Text("feed_selection_both")
                    .tag(FeedTimeSelection.both)
                Text("feed_selection_morning")
                    .tag(FeedTimeSelection.morning)
                Text("feed_selection_evening")
                    .tag(FeedTimeSelection.evening)
            }
            .pickerStyle(.segmented)
            .animation(.easeOut(duration: 0.8), value: dayType)
        }
    }
}
