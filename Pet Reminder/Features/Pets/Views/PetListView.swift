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
        ScrollView {
            VStack {
                petList
                /// Showing the detail page only if the selected pet has values(i.e. not empty)
                if selectedPet.name.isNotEmpty {
                    PetDetailView(pet: $selectedPet)
                }
            }
        }
        .toolbar(content: addButtonToolbar)
        .task(definePet)
        .navigationTitle(Text(.petNameTitle))
        .sheet(
            isPresented: $addPet,
            onDismiss: handleDismissAction,
            content: addPetView
        )
        .onReceive(NotificationCenter.default.publisher(for: .openPetByName)) { note in
            guard let raw = note.object as? String else { return }
            selectPet(named: raw)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openAddPet)) { _ in
            addPet = true
        }
        .overlay(content: noPetView)
    }

    @ViewBuilder
    private func addPetView() -> some View {
        AddPetView()
            .environment(notificationManager)
    }

    @ViewBuilder
    private func noPetView() -> some View {
        if pets.isEmpty {
            ContentUnavailableView(
                label: {
                    Label {
                        Text(.petNoPet)
                    } icon: {
                        Image(systemSymbol: .pawprintCircle)
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

    @ToolbarContentBuilder
    func addButtonToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if pets.count > 0 {
                Button {
                    addPet.toggle()
                } label: {
                    Image(systemSymbol: SFSymbol.plus)
                        .accessibilityLabel(Text(.addAnimalAccessibleLabel))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glassProminent)
                .tint(.accent)
                .clipShape(.circle)
            }
        }
    }

    private func handleDismissAction() {
        Logger.pets.info("Pet Add Sheet dismissed, context changed?: \(modelContext.hasChanges)")
        Logger.pets.info("Pet Count: \(pets.count)")
        /// If we have a new pet after there was none, or the new pet added and sorted via name
        /// we would like to switch first pet into the arrays first item.
        if pets.count > 0,
           let firstPet = pets.first {
            selectedPet = firstPet
        }
    }

    private func definePet() async {
        selectedPet = pets.first ?? .init()
        Logger
            .pets
            .debug("Pet Amount: \(pets.count)")
    }

    private func selectPet(named raw: String) {
        // First try a direct, case/diacritic-insensitive match
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
        // Fallback to slug match (handles spaces/punctuation differences)
        let target = slug(raw)
        if let slugged = pets.first(where: { slug($0.name) == target }) {
            selectedPet = slugged
            Logger.pets.info("PR: Deep link (slug) selected pet: \(slugged.name)")
        }
    }

    private func slug(_ term: String) -> String {
        let folded = term.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let allowed = CharacterSet.alphanumerics
        return String(folded.unicodeScalars.filter { allowed.contains($0) })
    }

    private var petList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                ForEach(pets, id: \.name) { pet in
                    Text(pet.name)
                        .foregroundStyle(
                            selectedPet == pet
                            ? Color.background
                            : Color.label
                        )
                        .bold(selectedPet == pet)
                        .padding(8)
                        .background(
                            selectedPet == pet
                            ? Color.green
                            : Color.green.opacity(0.3)
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

}

#if DEBUG
#Preview {
    NavigationStack {
        PetListView()
            .modelContainer(DataController.previewContainer)
            .environment(NotificationManager.shared)
    }
}
#endif
