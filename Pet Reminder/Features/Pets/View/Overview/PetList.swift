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

    @State private var addPet = false
    @State private var selectedPet: Pet?
    @State private var managedPet: Pet = .init()
    @State private var showManagePet = false

    @Environment(\.notification) private var notificationManager: NotificationManager
    
    var body: some View {
        list
            .toolbar(content: topActions)
            .task(setupInitials)
            .navigationTitle(Text(.petNameTitle))
            .navigationDestination(item: $selectedPet) { pet in
                PetDetail(pet: pet)
            }
            .sheet(isPresented: $addPet, onDismiss: handleDismissAction, content: addPetView)
            .sheet(isPresented: $showManagePet, onDismiss: dismissManagePet, content: managePetView)
            .onReceive(NotificationCenter.default.publisher(for: .openPetByName)) { note in
                guard let raw = note.object as? String else { return }
                selectPet(named: raw)
            }
            .onReceive(NotificationCenter.default.publisher(for: .openAddPet)) { _ in
                addPet = true
            }
    }
    
    @ViewBuilder var list: some View {
        if pets.isEmpty {
            noPetAdded
        } else {
            List(pets) { pet in
                HStack {
                    cell(for: pet)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .contentShape(.rect)
                .onTapGesture {
                    selectedPet = pet
                }
                .accessibility(addTraits: [.isButton])
                .accessibility(removeTraits: .isStaticText)
            }
        }
    }
    
    func cell(for pet: Pet) -> some View {
        VStack {
            HStack {
                CircleImage(
                    avatarSize: .avatar80,
                    imageData: pet.image,
                    kind: pet.kind
                )
                
                VStack(alignment: .leading) {
                    Text(pet.name)
                        .font(.title2)
                        .bold()
                    
                    if let breed = pet.breed,
                       breed.isNotEmpty {
                        Text(breed)
                            .font(.callout)
                    } else {
                        Button {
                            openManagePet(for: pet)
                        } label: {
                            Text(.petBreedAdd)
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .opacity(0.7)
                                .padding(.spacing4)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                        .foregroundStyle(.gray.opacity(0.7))
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text(birthdayTitle(for: pet))
                        .font(.footnote)
                }
            }
        }
    }
    
    @ViewBuilder
    func addPetView() -> some View {
        AddPet()
            .notification(notificationManager)
    }

    @ViewBuilder
    func managePetView() -> some View {
        ChangePetDetails(pet: $managedPet)
            .presentationCornerRadius(.sheetCornerRadius25)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
    }
    
    func birthdayTitle(for pet: Pet) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: pet.birthday, to: .now)
        let years = components.year ?? .zero
        let months = components.month ?? .zero
        
        if years <= .zero {
            return String(localized: "pet_birthday_months \(months)")
        } else {
            return String(localized: "pet_birthday_years \(years)")
        }
    }
    
    var noPetAdded: some View {
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
    
    @ToolbarContentBuilder
    func topActions() -> some ToolbarContent {
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
}

// MARK: - Helper Functions
private extension PetList {
    
    func setupInitials() async {
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

    func openManagePet(for pet: Pet) {
        managedPet = pet
        showManagePet = true
    }

    func dismissManagePet() {
        managedPet = .init()
    }
    
    func handleDismissAction() {
        Logger.pets.info("Pet Add Sheet dismissed, context changed?: \(modelContext.hasChanges)")
        Logger.pets.info("Pet Count: \(pets.count)")
        logDuplicateNamesIfAny()
    }
}

private extension CGFloat {
    static let avatar80: Self = 80
}

#if DEBUG
#Preview("Multiple Pets") {
    NavigationStack {
        PetList()
            .modelContainer(DataController.previewContainer)
            .notification(NotificationManager.shared)
            .navigationTitle(Text("Pets"))
    }
}

#Preview("Empty Pets") {
    NavigationStack {
        PetList()
            .modelContainer(DataController.emptyContainer)
            .notification(NotificationManager.shared)
            .navigationTitle(Text("Pets"))
    }
}
#endif
