//
//  PetListView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared
import SFSafeSymbols

struct PetListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Pet.name)]) var pets: [Pet]

    @State private var selectedPet: Pet?
    @State private var addPet = false

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    petList
                    PetDetailView(pet: $selectedPet)
                }
            }
            .toolbar(content: addButtonToolbar)
            .onAppear {
                selectedPet = pets.first
            }
            .navigationTitle(petListTitle)
            .navigationBarTitleTextColor(.accent)
            .fullScreenCover(
                isPresented: $addPet,
                onDismiss: {
                    selectedPet = pets.first
                    Logger
                        .pets
                        .debug("Pet Amount: \(pets.count)")
                },
                content: {
                    AddPetView(
                        viewModel: .init(notificationManager: .init())
                )
            })
        }
        .overlay {
            if pets.isEmpty {
                ContentUnavailableView(label: {
                    Label("pet_no_pet", systemImage: "pawprint.circle")
                }, actions: {
                    Button("pet_add_pet", action: {
                        addPet.toggle()
                    })
                    .buttonStyle(.bordered)
                    .tint(.accent)
                })
            }
        }
    }

    private var petList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                ForEach(pets, id: \.name) { pet in
                    Text(pet.name)
                        .foregroundStyle(
                            selectedPet == pet
                            ? .white
                            : .black
                        )
                        .bold(selectedPet == pet)
                        .padding(8)
                        .background(
                            selectedPet == pet
                            ? Color.accent
                            : Color.accent.opacity(0.3)
                        )
                        .clipShape(.capsule)
                        .animation(.snappy, value: selectedPet)
                    .onTapGesture {
                        selectedPet = pet
                        Logger
                            .pets
                            .info("PR: Pet Selected: \(pet.name)")
                    }
                    .padding(.leading)
                }
            }

        }
    }

    private func defineColor(pet: Pet) -> Color {
        selectedPet?.name == pet.name ? Color.yellow : Color.clear
    }

    private var petListTitle: Text {
        Text("pet_name_title")
    }

    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if pets.count > 0 {
                Button(action: {
                    self.addPet.toggle()
                }, label: {
                    Image(systemSymbol: SFSymbol.plusCircleFill)
                        .accessibilityLabel(Text("add_animal_accessible_label"))
                        .foregroundStyle(.accent)
                        .font(.title)
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        PetListView()
            .modelContainer(DataController.previewContainer)
            .environment(NotificationManager())
    }
}
