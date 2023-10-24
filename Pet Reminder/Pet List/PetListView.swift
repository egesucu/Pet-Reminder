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

struct PetListView: View {

    @Environment(\.modelContext) private var modelContext

    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    @AppStorage(Strings.demoDataOccured) var demoDataOccured = true

    @Query(sort: [.init(\Pet.name)]) var pets: [Pet]

    @State private var selectedPet: Pet?
    @State private var addPet = false
    @State private var notificationManager = NotificationManager()

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
                performDemoDataDeletion()
                selectedPet = pets.first
            }
            .navigationTitle(petListTitle)
            .fullScreenCover(isPresented: $addPet, onDismiss: {
                selectedPet = pets.first
                Logger
                    .viewCycle
                    .debug("Pet Amount: \(pets.count)")
            }, content: {
                NewAddPetView()
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
                    .tint(tintColor)
                })
            }
        }
    }

    private var petList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(pets, id: \.name) { pet in
                    VStack {
                        ESImageView(data: pet.image)
                            .clipShape(Circle())
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(
                                        defineColor(pet: pet),
                                        lineWidth: 5
                                    )
                            )
                        Text(pet.name)
                    }
                    .onTapGesture {
                        selectedPet = pet
                        Logger
                            .viewCycle
                            .info("PR: Pet Selected: \(pet.name)")
                    }
                    .padding([.top, .leading])

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
                    Image(systemName: SFSymbols.add)
                        .accessibilityLabel(Text("add_animal_accessible_label"))
                        .foregroundColor(tintColor)
                        .font(.title)
                })
            }
        }
    }

    @available(swift, deprecated: 6.0, message: "This is a hotfix function introduced in Pet Reminder 5.6.1 and will be removed in the 5.8 or newer release.")
    func performDemoDataDeletion() {
        if demoDataOccured {
            for name in Strings.demoPets {
                let pet = pets.filter({ $0.name == name}).first
                if let pet {
                    deletePet(pet: pet)
                    self.notificationManager.removeAllNotifications(of: pet.name)
                }
            }
            demoDataOccured = false
        }
    }

    @available(swift, deprecated: 6.0, message: "This is a hotfix function introduced in Pet Reminder 5.6.1 and will be removed in the 5.8 or newer release.")
    func deletePet(pet: Pet) {
        modelContext.delete(pet)
        if pets.count > 0 {
            selectedPet = pets.first
        } else {
            selectedPet = nil
        }
    }
}

#Preview {
    NavigationStack {
        PetListView()
            .modelContainer(PreviewSampleData.container)
    }
}
