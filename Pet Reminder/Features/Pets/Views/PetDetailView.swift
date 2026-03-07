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
        VStack(spacing: PRSpacing.spacing8) {
            VStack(spacing: 0) {
                if let imageData = pet.image,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .petImageStyle()
                        .padding(.horizontal, PRSpacing.spacing20)
                        .padding(.top, PRSpacing.spacing20)
                        .frame(width: PRComponentSize.avatar300, height: PRComponentSize.avatar300)
                        .zIndex(2)
                } else {
                    Image(.generateDefaultData(type: pet.type))
                        .petImageStyle()
                        .padding(.horizontal, PRSpacing.spacing20)
                        .padding(.top, PRSpacing.spacing20)
                        .frame(width: PRComponentSize.avatar300, height: PRComponentSize.avatar300)
                        .zIndex(2)
                }
                FeedListView(pet: $pet)
                    .frame(width: 320, height: PRComponentSize.feedCardHeight100)
                    .padding(.horizontal, PRSpacing.spacing32)
                    .padding(.top, PRSpacing.spacing60)
                    .padding(.bottom, PRSpacing.spacing8)
                    .background(
                        RoundedRectangle(cornerRadius: PRRadius.radius20)
                            .stroke(yellowGradient, lineWidth: 4)
                    )
                    .offset(x: 0, y: -PRSpacing.spacing60)

            }
            HStack(spacing: PRSpacing.spacing12) {
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
                        Image(systemName: "fork.knife")
                            .font(.system(size: PRIconSize.icon24, weight: .regular))
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
                        Image(systemName: "syringe.fill")
                            .font(.system(size: PRIconSize.icon24, weight: .regular))
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
    }

    var detailView: some View {
        FeedListView(pet: $pet)
    }

    func defineMorningFeed() -> String {
        let todaysFeed = pet
            .feeds?
            .first { Calendar.current.isDateInToday($0.feedDate ?? .now) }
        let isFed = todaysFeed?.morningFed ?? false

        return isFed ? "checkmark" : "sun.max"
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
