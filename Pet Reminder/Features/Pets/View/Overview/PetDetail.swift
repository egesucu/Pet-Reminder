//
//  PetDetail.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import Shared
import SwiftData

struct PetDetail: View {

    let pet: Pet
    @State private var showFeedHistory = false
    @State private var showVaccines = false

    @Environment(\.modelContext) private var modelContext

    let yellowGradient = LinearGradient(
        colors: [.yellow, .yellow.opacity(0.6), .yellow.opacity(0.4)],
        startPoint: .bottom,
        endPoint: .top
    )

    var body: some View {
        VStack(spacing: .spacing8) {
            VStack(spacing: .zero) {
                CircleImage(
                    avatarSize: .avatar120,
                    imageData: pet.image,
                    kind: pet.kind
                )
                .zIndex(2)
                
                FeedList(pet: pet)
                    .frame(width: 320, height: .feedCardHeight100)
                    .padding(.horizontal, .spacing32)
                    .padding(.top, .spacing60)
                    .padding(.bottom, .spacing8)
                    .background(
                        RoundedRectangle(cornerRadius: .radius20)
                            .stroke(yellowGradient, lineWidth: 4)
                    )
                    .offset(x: 0, y: -.spacing60)

            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.accent)
                    .onTapGesture {
                        Logger
                            .pets
                            .info("PR: Feed History Tapped, pet name: \(pet.name)")
                        showFeedHistory.toggle()
                    }
            }
            
            ToolbarSpacer(placement: .bottomBar)
            
            ToolbarItem(placement: .bottomBar) {
                Image(systemName: "syringe.fill")
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        Logger
                            .pets
                            .info("PR: Vaccine History Tapped")
                        showVaccines.toggle()
                    }
            }
            
        }
        .sheet(isPresented: $showFeedHistory) {
            FeedHistory(feeds: pet.feeds)
                .presentationDetents([.medium,.large])
        }
        .sheet(isPresented: $showVaccines) {
            VaccineHistory(pet: pet)
                .presentationDetents([.medium,.large])
        }
        .navigationTitle(Text("pet_name_title \(pet.name)"))
    }

    var detailView: some View {
        FeedList(pet: pet)
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
        PetDetail(
            pet: .preview
        )
        .modelContainer(DataController.previewContainer)
    }
}
#endif
