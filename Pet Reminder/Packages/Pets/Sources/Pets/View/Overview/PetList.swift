//
//  PetList.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 28.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Reminders
import SwiftUI
import SwiftData
import OSLog
import Shared
import SharedUI
import PetCare
#if DEBUG
import PreviewSupport
#endif

@MainActor
public struct PetList: View {

    @Environment(\.modelContext) private var modelContext
    private let request: PetRouteRequest?
    private let onSelectionChanged: (UUID?) -> Void
    private let openPetWindow: ((UUID) -> Void)?
    private let onRequestHandled: (PetRouteRequest) -> Void

    public init(request: PetRouteRequest? = nil, onRequestHandled: @escaping (PetRouteRequest) -> Void = { _ in }, openPetWindow: ((UUID) -> Void)? = nil, onSelectionChanged: @escaping (UUID?) -> Void = { _ in }) {
        self.onSelectionChanged = onSelectionChanged
        self.openPetWindow = openPetWindow
        self.request = request
        self.onRequestHandled = onRequestHandled
    }

    @Query(sort: [.init(\Pet.name)]) var pets: [Pet]

    @SceneStorage("pets.selectedID") private var storedPetID = ""
    @SceneStorage("pets.search") private var searchText = ""
    @State private var isSearching = false
    @State private var historyRequest: PetHistoryRequest?
    @State private var addPet = false
    @State private var selectedPet: Pet?
    @State private var managedPet: Pet = .init()
    @State private var showManagePet = false

    @Environment(NotificationManager.self) private var notificationManager

    public var body: some View {
        NavigationSplitView {
            list
                .searchable(text: $searchText, isPresented: $isSearching,
                            prompt: Text(SharedStrings.resource("Search pets")))
                .scrollContentBackground(.hidden)
                .background(Color.groupedBackground)
                .containerBackground(Color.groupedBackground, for: .navigation)
                .toolbarBackground(Color.groupedBackground, for: .navigationBar)
                .navigationTitle(Text(SharedStrings.petNameTitle))
                .toolbar(content: topActions)
                .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 460)
        } detail: {
            NavigationStack {
                Group {
                    if let selectedPet {
                        PetDetail(pet: selectedPet, historyRequest: historyRequest)
                            .id(selectedPet.persistentModelID)
                    } else {
                        ContentUnavailableView(
                            SharedStrings.resource("Select a pet"),
                            systemImage: "pawprint.circle",
                            description: Text(SharedStrings.resource("Choose a pet to see today's care and history."))
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.groupedBackground)
                .containerBackground(Color.groupedBackground, for: .navigation)
                .toolbarBackground(Color.groupedBackground, for: .navigationBar)
            }
        }
            .navigationSplitViewStyle(.balanced)
            .containerBackground(Color.groupedBackground, for: .navigationSplitView)
            .background(Color.groupedBackground.ignoresSafeArea())
            .toolbarBackground(Color.groupedBackground, for: .tabBar)
            .task(setupInitials)
            .onChange(of: request, initial: true) { _, _ in
                consumePendingPet()
            }
            .onChange(of: pets.map { "\($0.intentID?.uuidString ?? ""):\($0.name)" }) { _, _ in
                if let selectedPet, !pets.contains(where: { $0.persistentModelID == selectedPet.persistentModelID }) {
                    self.selectedPet = nil
                }
                consumePendingPet()
            }
            .onChange(of: selectedPet?.intentID) { _, id in
                storedPetID = id?.uuidString ?? ""
                onSelectionChanged(id)
                if historyRequest?.petID != id { historyRequest = nil }
            }
            .sheet(isPresented: $addPet, onDismiss: handleDismissAction, content: addPetView)
            .sheet(isPresented: $showManagePet, onDismiss: dismissManagePet, content: managePetView)

    }

    @ContentBuilder var list: some View {
        if pets.isEmpty {
            noPetAdded
        } else {
            List(filteredPets, selection: $selectedPet) { pet in
                NavigationLink(value: pet) {
                    cell(for: pet)
                }
                .contextMenu {
                    Button(SharedStrings.edit, systemImage: "pencil") { openManagePet(for: pet) }
                    Button(SharedStrings.feedHistoryTitle, systemImage: "fork.knife") { openHistory(.feedHistory, for: pet) }
                    Button(SharedStrings.vaccineHistoryTitle, systemImage: "syringe") { openHistory(.vaccines, for: pet) }
                    if let openPetWindow, let id = pet.intentID {
                        Button(SharedStrings.resource("Open in New Window"), systemImage: "rectangle.on.rectangle") {
                            openPetWindow(id)
                        }
                    }
                }
            }
            .overlay {
                if filteredPets.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    private var filteredPets: [Pet] {
        pets.filter { PetSearch.matches(name: $0.name, breed: $0.breed, query: searchText) }
    }

    private func openHistory(_ destination: PetHistoryDestination, for pet: Pet) {
        selectedPet = pet
        // A fresh token also lets the same menu action reopen a popped history.
        historyRequest = PetHistoryRequest(destination: destination, petID: pet.intentID)
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
                            Text(SharedStrings.petBreedAdd)
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

    @ContentBuilder
    func addPetView() -> some View {
        AddPet()
            .notification(notificationManager)
    }

    @ContentBuilder
    func managePetView() -> some View {
        ChangePetDetails(pet: $managedPet, notificationManager: notificationManager)
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
            return String(localized: "pet_birthday_months \(months)", bundle: SharedResources.bundle)
        } else {
            return String(localized: "pet_birthday_years \(years)", bundle: SharedResources.bundle)
        }
    }

    var noPetAdded: some View {
        ContentUnavailableView(
            label: {
                Label {
                    Text(SharedStrings.petNoPet)
                } icon: {
                    Image(systemName: "pawprint.circle")
                }
            },
            actions: {
                Button {
                    addPet.toggle()
                } label: {
                    Text(SharedStrings.petAddPet)
                }
                .buttonStyle(.bordered)
                .tint(.accent)
            }
        )
    }

    @ContentBuilder
    func topActions() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                addPet.toggle()
            } label: {
                Label(SharedStrings.addAnimalAccessibleLabel, systemImage: "plus")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Color.background)
            }
            .buttonStyle(.glassProminent)
            .tint(.accent)
            .clipShape(.circle)
            .keyboardShortcut("n")
            .disabled(addPet || showManagePet)
        }
        ToolbarItem(placement: .secondaryAction) {
            Button(SharedStrings.resource("Search pets"), systemImage: "magnifyingglass") { isSearching = true }
                .keyboardShortcut("f")
        }
    }
}

// MARK: - Helper Functions
private extension PetList {

    func consumePendingPet() {
        guard let request else { return }
        do {
            switch request.destination {
            case .pet(let id):
                guard let pet = try PetRouteResolver.resolve(id: id, in: modelContext) else { return }
                searchText = ""
                selectedPet = pet
            case .namedPet(let name):
                guard selectPet(named: name) else { return }
            case .addPet:
                addPet = true
            }
            onRequestHandled(request)
        } catch {
            Logger.pets.error("Failed to open requested pet: \(error.localizedDescription)")
        }
    }

    func setupInitials() async {
        logDuplicateNamesIfAny()
        if request == nil, let id = UUID(uuidString: storedPetID) {
            selectedPet = try? PetRouteResolver.resolve(id: id, in: modelContext)
            if selectedPet == nil { storedPetID = "" }
        }
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--store-screenshots"),
           let index = arguments.firstIndex(of: "--screenshot-screen"),
           arguments.indices.contains(index + 1),
           arguments[index + 1] != "pets" {
            selectedPet = pets.first { $0.name == "Luna" }
        }
        #endif
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

    func selectPet(named name: String) -> Bool {
        guard let pet = PetRouteResolver.resolve(name: name, among: pets) else { return false }
        searchText = ""
        selectedPet = pet
        return true
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
            .environment(PetCareService(container: PreviewData.previewContainer))
            .modelContainer(PreviewData.previewContainer)
            .notification(NotificationManager())
            .navigationTitle(Text(SharedStrings.petNameTitle))
    }
}

#Preview("Empty Pets") {
    NavigationStack {
        PetList()
            .environment(PetCareService(container: PreviewData.emptyContainer))
            .modelContainer(PreviewData.emptyContainer)
            .notification(NotificationManager())
            .navigationTitle(Text(SharedStrings.petNameTitle))
    }
}
#endif
