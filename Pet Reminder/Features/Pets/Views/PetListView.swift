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

extension ReferenceWritableKeyPath: @retroactive @unchecked Sendable { }

struct PetListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Pet.name)]) var pets: [Pet]
    
    @State private var selectedPet: Pet = .init()
    @State private var addPet = false
    
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager
    
    var body: some View {
        ZStack {
            petsOverview
            if addPet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                addPetView()
                    .padding()
            }
        }
        .animation(.easeInOut, value: addPet)
    }
    
    private var petsOverview: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    petList
                    /// Showing the detail page only if the selected pet has values(i.e. not empty)
                    if selectedPet.name.isNotEmpty {
                        PetDetailView(pet: $selectedPet)
                    }
                }
            }
            .toolbar {
                addButtonToolbar()
            }
            .onAppear {
                Task { await definePet() }
            }
            .navigationTitle(petListTitle)
            .navigationBarTitleTextColor(.accent)
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
        .onChange(of: addPet) {
            if !addPet {
                Logger.pets.info("Pet Add Sheet dismissed, context changed?: \(modelContext.hasChanges)")
                Logger.pets.info("Pet Count: \(pets.count)")
                /// If we have a new pet after there was none, or the new pet added and sorted via name
                /// we would like to switch first pet into the arrays first item.
                if pets.count > 0,
                   let firstPet = pets.first {
                    selectedPet = firstPet
                }
            }
        }
    }
    
    @ViewBuilder
    private func addPetView() -> some View {
        AddPetView() {
            withAnimation { toggleAddPet() }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .environment(notificationManager)
        .transition(.move(edge: .bottom))
        .zIndex(1)
        .ignoresSafeArea()
    }
    
    private func updatePets() {
        Task { await definePet() }
    }
    
    private func definePet() async {
        selectedPet = pets.first ?? .init()
        Logger
            .pets
            .debug("Pet Amount: \(pets.count)")
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
        selectedPet == pet
        ? Color.yellow
        : Color.clear
    }
    
    private var petListTitle: Text {
        Text("pet_name_title")
    }
    
    private func toggleAddPet() {
        addPet.toggle()
    }
    
    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if pets.count > 0 {
                Button(action: toggleAddPet) {
                    Image(systemSymbol: SFSymbol.plusCircleFill)
                        .accessibilityLabel(Text("add_animal_accessible_label"))
                        .foregroundStyle(.accent)
                        .font(.title)
                }
                .opacity(addPet ? 0 : 1)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PetListView()
            .modelContainer(DataController.previewContainer)
            .environment(NotificationManager.shared)
    }
}
