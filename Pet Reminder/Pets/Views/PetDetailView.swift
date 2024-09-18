//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog


struct PetDetailView: View {

    @Binding var pet: Pet?
    @State private var showFeedHistory = false
    @State private var showVaccines = false

    

    var body: some View {
        VStack {
            if let pet {
                ESImageView(data: pet.image)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .frame(width: 250, height: 250)
                Spacer()
                FeedListView(pet: $pet)
                    .padding(.bottom, 50)
                HStack {
                    Button {
                        Logger
                            .pets
                            .info("PR: Feed History Tapped, pet name: \(pet.name)")
                        showFeedHistory.toggle()
                    } label: {
                        Label {
                            Text("feeds_title")
                        } icon: {
                            Image(systemName: "fork.knife.circle.fill")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.accent)
                    Button {
                        Logger
                            .pets
                            .info("PR: Vaccine History Tapped")
                        showVaccines.toggle()
                    } label: {
                        Label {
                            Text("vaccines_title")
                        } icon: {
                            Image(systemName: "syringe.fill")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showFeedHistory) {
            if let pet {
                FeedHistory(feeds: pet.feeds)
            }
        }
        .fullScreenCover(isPresented: $showVaccines) {
            VaccineHistoryView(pet: $pet)
        }
        .navigationTitle(Text("pet_name_title \(pet?.name ?? "")"))
    }
}

#Preview(traits: .portrait) {
    NavigationStack {
        PetDetailView(
            pet: .constant(.preview)
        )
            .modelContainer(DataController.previewContainer)
    }
    .navigationViewStyle(.stack)
}
