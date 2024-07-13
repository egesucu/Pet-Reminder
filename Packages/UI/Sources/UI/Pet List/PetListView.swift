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
import SharedModels

public struct PetListView: View {

    @Environment(\.modelContext) private var modelContext

    @AppStorage(Strings.tintColor) var tintColor = ESColor(color: Color.accentColor)

    @Query(sort: [.init(\Pet.name)]) public var pets: [Pet]

    @State private var selectedPet: Pet?
    @State private var addPet = false

    @Environment(NotificationManager.self) private var notificationManager: NotificationManager?

    public var body: some View {
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
            .fullScreenCover(
                isPresented: $addPet,
                onDismiss: {
                    selectedPet = pets.first
                    Logger
                        .pets
                        .debug("Pet Amount: \(pets.count)")
                },
                content: {
                    NewAddPetView(
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
                    .tint(tintColor.color)
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
                            .pets
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
                        .foregroundStyle(tintColor.color)
                        .font(.title)
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        PetListView()
            .modelContainer(PreviewSampleData.container)
            .environment(NotificationManager())
    }
}
