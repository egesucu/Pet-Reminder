//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

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
        .navigationTitle(Text("pet_name_title \(pet.name)"))
    }
// swiftlint: disable trailing_whitespace
    func filterFeeds() -> [Feed] {
        return pet.feeds?.filter({ feed in
            feed.morningFedStamp != nil || feed.eveningFedStamp != nil
        }).sorted(by: {
            $0.feedDate ?? .now > $1.feedDate ?? .now
        }) ?? []
        
    }
// swiftlint: enable trailing_whitespace

    func getLatestFeed() {
        if let feeds = pet.feeds {
            if let lastFeed = feeds.last {
                if let date = lastFeed.feedDate {
                    if Calendar.current.isDateInToday(date) {
                        // We have a feed.
                        morningOn = lastFeed.morningFed ?? false
                        eveningOn = lastFeed.eveningFed ?? false
                    }
                }
            }
        }
    }
}

#Preview(traits: .portrait) {
    MainActor.assumeIsolated {
        NavigationView {
            PetDetailView(pet: PreviewSampleData.previewPet)
                .modelContainer(PreviewSampleData.container)
        }.navigationViewStyle(.stack)
    }
}
