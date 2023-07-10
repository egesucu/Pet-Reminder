//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetDetailView: View {

    var pet: Pet
    var feed: Feed?
    @State private var morningOn = false
    @State private var eveningOn = false
    @State private var showFeedHistory = false
    @State private var showVaccines = false

    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        VStack {
            ESImageView(data: pet.image)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .frame(
                    minWidth: 50,
                    idealWidth: 100,
                    maxWidth: 200,
                    minHeight: 50,
                    idealHeight: 100,
                    maxHeight: 200,
                    alignment: .center
                )
            Spacer()
            FeedListView(
                morningOn: $morningOn,
                eveningOn: $eveningOn,
                pet: pet
            )
            .padding(.bottom, 50)

            HStack {
                Button {
                    showFeedHistory.toggle()
                } label: {
                    Label("feeds_title", systemImage: "fork.knife.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(tintColor)
                Button {
                    showVaccines.toggle()
                } label: {
                    Label("vaccines_title", systemImage: "syringe.fill")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }

            Spacer()
        }
        .onAppear {
            getLatestFeed()
        }
        .fullScreenCover(isPresented: $showFeedHistory, content: {
            FeedHistory(feeds: filterFeeds())
        })
        .fullScreenCover(isPresented: $showVaccines, content: {
            VaccineHistoryView(pet: pet)
        })
        .navigationTitle(Text("pet_name_title \(pet.name ?? "")"))
    }
// swiftlint: disable trailing_whitespace
    func filterFeeds() -> [Feed] {
        return (pet.feeds?.allObjects as? [Feed])?.filter({ feed in
            feed.morningFedStamp != nil || feed.eveningFedStamp != nil
        }).sorted(by: {
            $0.feedDate ?? .now > $1.feedDate ?? .now
        }) ?? []
        
    }
// swiftlint: enable trailing_whitespace

    func getLatestFeed() {
        if let feeds = pet.feeds,
        let feedArray = feeds.allObjects as? [Feed]{
            if let lastFeed = feedArray.last {
                if let date = lastFeed.feedDate {
                    if Calendar.current.isDateInToday(date) {
                        // We have a feed.
                        morningOn = lastFeed.morningFed 
                        eveningOn = lastFeed.eveningFed 
                    }
                }
            }
        }
    }
}

// #Preview {
//    MainActor.assumeIsolated {
//        PetDetailView(pet: PreviewSampleData.previewPet)
//            .modelContainer(PreviewSampleData.container)
//    }
//    
// }

struct FeedListView: View {

    @Binding var morningOn: Bool
    @Binding var eveningOn: Bool

    var pet: Pet = .init()

    let feedback = UINotificationFeedbackGenerator()

    var body: some View {
        HStack(spacing: 30) {
            switch pet.selection {
            case .morning:
                MorningCheckboxView(morningOn: $morningOn)
                    .onChange(of: morningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .morning, value: morningOn)
                    })
                    .onTapGesture {
                        morningOn.toggle()
                    }
            case .evening:
                EveningCheckboxView(eveningOn: $eveningOn)
                    .onChange(of: eveningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .evening, value: eveningOn)
                    })
                    .onTapGesture {
                        eveningOn.toggle()
                    }
            case .both:
                MorningCheckboxView(morningOn: $morningOn)
                    .onChange(of: morningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .morning, value: morningOn)
                    })
                    .onTapGesture {
                        morningOn.toggle()
                    }
                EveningCheckboxView(eveningOn: $eveningOn)
                    .onChange(of: eveningOn, {
                        feedback.notificationOccurred(.success)
                        updateFeed(type: .evening, value: eveningOn)
                    })
                    .onTapGesture {
                        eveningOn.toggle()
                    }
            }
        }
    }

    var todaysFeeds: [Feed] {
        (pet.feeds?.allObjects as? [Feed])?.filter { feed in
            Calendar.current.isDateInToday(feed.feedDate ?? .now)
        } ?? []

    }

    func updateFeed(type: FeedTimeSelection, value: Bool) {

        if todaysFeeds.isEmpty {
            addFeedForToday(value: value)
        } else {
            if let feedSet = pet.feeds,
               let feeds = feedSet.allObjects as? [Feed],
               let lastFeed = feeds.last {
                switch type {
                case .morning:
                    lastFeed.morningFedStamp = value ? .now : nil
                    lastFeed.morningFed = value
                case .evening:
                    lastFeed.eveningFedStamp = value ? .now : nil
                    lastFeed.eveningFed = value
                default:
                    break
                }
                if value {
                    lastFeed.feedDate = .now
                }
            }
        }
    }

    func addFeedForToday(value: Bool) {
        let feed = Feed()

        switch pet.selection {
        case .both:
            break
        case .morning:
            feed.morningFedStamp = value ? .now : nil
            feed.morningFed = value
        case .evening:
            feed.eveningFedStamp = value ? .now : nil
            feed.eveningFed = value
        }
        pet.addToFeeds(feed)
    }

}

struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {

        return NavigationView {
            PetDetailView(pet: .init())
        }.navigationViewStyle(.stack)
            .previewInterfaceOrientation(.portrait)
    }
}
