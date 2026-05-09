//
//  PetList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData
import OSLog
import Shared

struct PetList: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: [.init(\Pet.name)]) var pets: [Pet]

    @State private var selectedPet: Pet = .init()
    @State private var addPet = false

    @Environment(\.notification) private var notificationManager: NotificationManager

    var body: some View {
        ScrollView {
            VStack(spacing: .spacing8) {
                petList
                /// Showing the detail page only if the selected pet has values(i.e. not empty)
                if selectedPet.name.isNotEmpty {
                    PetDetail(pet: $selectedPet)
                }
            }
        }
        .toolbar(content: addButtonToolbar)
        .task(setupInitials)
        .navigationTitle(Text(.petNameTitle))
        .sheet(isPresented: $addPet, onDismiss: handleDismissAction, content: addPetView)
        .onReceive(NotificationCenter.default.publisher(for: .openPetByName)) { note in
            guard let raw = note.object as? String else { return }
            selectPet(named: raw)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openAddPet)) { _ in
            addPet = true
        }
        .overlay(content: noPetView)
    }
}

// MARK: - UI Helpers
private extension PetList {
    var petList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: .spacing20) {
                ForEach(pets, id: \.name) { pet in
                    Chip(
                        title: pet.name,
                        selected: selectedPet == pet
                    ) {
                        selectedPet = pet
                        Logger
                            .pets
                            .info("PR: Pet Selected: \(pet.name)")
                    }
                }
            }
        }
        .padding(.horizontal, .spacing8)
    }
    
    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if pets.isNotEmpty {
                Button {
                    addPet.toggle()
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel(Text(.addAnimalAccessibleLabel))
                        .foregroundStyle(Color.background)
                }
                .buttonStyle(.glassProminent)
                .tint(.accent)
                .clipShape(.circle)
            }
        }
    }
    
    @ViewBuilder
    func addPetView() -> some View {
        AddPet()
            .notification(notificationManager)
    }

    @ViewBuilder
    func noPetView() -> some View {
        if pets.isEmpty {
            ContentUnavailableView(
                label: {
                    Label {
                        Text(.petNoPet)
                    } icon: {
                        Image(systemName: "pawprint.circle")
                    }
                },
                actions: {
                    Button {
                        addPet.toggle()
                    } label: {
                        Text(.petAddPet)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accent)
                }
            )
        }
    }
}

// MARK: - Helper Functions
private extension PetList {
    
    func setupInitials() async {
        await definePet()
        logDuplicateNamesIfAny()
    }
    
    func logDuplicateNamesIfAny() {
        let names = pets.map(\.name)
        let duplicates = Dictionary(grouping: names, by: { $0 })
            .filter { $1.count > 1 }
            .keys
        if duplicates.isEmpty == false {
            Logger.pets.error("Duplicate pet names detected: \(duplicates.joined(separator: ", "))")
        }
    }
    
    func slug(_ term: String) -> String {
        let folded = term.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let allowed = CharacterSet.alphanumerics
        return String(folded.unicodeScalars.filter { allowed.contains($0) })
    }
    
    func selectPet(named raw: String) {
        if let exact = pets.first(
            where: {
                $0.name.compare(
                    raw,
                    options: [
                        .caseInsensitive,
                        .diacriticInsensitive
                    ]
                ) == .orderedSame
            }) {
            selectedPet = exact
            Logger.pets.info("PR: Deep link selected pet: \(exact.name)")
            return
        }
        let target = slug(raw)
        if let slugged = pets.first(where: { slug($0.name) == target }) {
            selectedPet = slugged
            Logger.pets.info("PR: Deep link (slug) selected pet: \(slugged.name)")
        }
    }
    
    func definePet() async {
        selectedPet = pets.first ?? .init()
        Logger
            .pets
            .debug("Pet Amount: \(pets.count)")
    }
    
    func handleDismissAction() {
        Logger.pets.info("Pet Add Sheet dismissed, context changed?: \(modelContext.hasChanges)")
        Logger.pets.info("Pet Count: \(pets.count)")
        /// If we have a new pet after there was none, or the new pet added and sorted via name
        /// we would like to switch first pet into the arrays first item.
        if pets.isNotEmpty,
           let firstPet = pets.first {
            selectedPet = firstPet
        }
        logDuplicateNamesIfAny()
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PetList()
            .modelContainer(DataController.previewContainer)
            .notification(NotificationManager.shared)
    }
}
#endif
