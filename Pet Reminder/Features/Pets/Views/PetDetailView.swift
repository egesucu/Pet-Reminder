//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import Shared
import SwiftData
import SFSafeSymbols

struct PetDetailView: View {

    @Binding var pet: Pet
    @State private var showFeedHistory = false
    @State private var showVaccines = false

    @Environment(\.modelContext) private var modelContext

    let yellowGradient = LinearGradient(
        colors: [.yellow, .yellow.opacity(0.6), .yellow.opacity(0.4)],
        startPoint: .bottom,
        endPoint: .top
    )

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 0) {
                if let imageData = pet.image,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .petImageStyle()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .frame(width: 300, height: 300)
                        .zIndex(2)
                } else {
                    Image(.generateDefaultData(type: pet.type))
                        .petImageStyle()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .frame(width: 300, height: 300)
                        .zIndex(2)
                }
                FeedListView(pet: $pet)
                    .frame(width: 320, height: 100)
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                    .padding(.bottom, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(yellowGradient, lineWidth: 4)
                    )
                    .offset(x: 0, y: -60)

            }
            HStack {
                Button {
                    Logger
                        .pets
                        .info("PR: Feed History Tapped, pet name: \(pet.name)")
                    showFeedHistory.toggle()
                } label: {
                    Label {
                        Text(.feedsTitle)
                            .font(.title)
                            .foregroundStyle(Color.background)
                    } icon: {
                        Image(systemSymbol: .forkKnife)
                            .font(.title)
                            .foregroundStyle(Color.background)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.accent)
                Button {
                    Logger
                        .pets
                        .info("PR: Vaccine History Tapped")
                    showVaccines.toggle()
                } label: {
                    Label {
                        Text(.vaccinesTitle)
                            .font(.title)
                            .foregroundStyle(Color.background)
                    } icon: {
                        Image(systemSymbol: .syringeFill)
                            .font(.title)
                            .foregroundStyle(Color.background)
                    }
                }
                .buttonStyle(.glassProminent)
                .tint(.blue)
            }
        }
        .fullScreenCover(isPresented: $showFeedHistory) {
            FeedHistory(feeds: pet.feeds)
        }
        .fullScreenCover(isPresented: $showVaccines) {
            VaccineHistoryView(pet: $pet)
        }
        .navigationTitle(Text("pet_name_title \(pet.name)"))
        .onAppear {
            setPetFeedSelection()
        }
    }

    /// This function ensures that each pet has a selection.
    /// Coming from early versions, we used to set choice values, but now we require feedSelection.
    func setPetFeedSelection() {
        if pet.feedSelection == nil {
            switch pet.choice {
            case 0:
                pet.feedSelection = .morning
            case 1:
                pet.feedSelection = .evening
            default:
                pet.feedSelection = .both
            }
            try? modelContext.save()
        }
    }

    var detailView: some View {
        FeedListView(pet: $pet)
    }

    func defineMorningFeed() -> SFSymbol {
        let todaysFeed = pet
            .feeds?
            .first { Calendar.current.isDateInToday($0.feedDate ?? .now) }
        let isFed = todaysFeed?.morningFed ?? false

        return isFed ? .checkmark : .sunMax
        }
}

#if DEBUG
#Preview {
    NavigationStack {
        PetDetailView(
            pet: .constant(.preview)
        )
        .modelContainer(DataController.previewContainer)
    }
}
#endif
