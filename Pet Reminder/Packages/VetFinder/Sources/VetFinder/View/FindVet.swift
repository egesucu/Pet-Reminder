//
//  FindVet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import OSLog
import Shared
import SharedUI

@MainActor
public struct FindVet: View {

    private let vetService: any VetService

    @State private var searchText = String(localized: SharedStrings.defaultVetText)
    @State private var isSearching = false

    @State private var userLocation: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    @State private var searchedLocations: [Pin] = []
    @State private var selectedLocation: Pin?
    @State private var mapViewStatus: MapViewStatus = .none

    public init(service: any VetService, searchText: String = String(localized: SharedStrings.defaultVetText)) {
        self.vetService = service
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        NavigationStack {
            mapView
                .navigationTitle(Text(SharedStrings.findVetTitle))
                .overlay(locationNotAvailable)
        }
        .task {
            await vetService.requestMapPermissions()
            await setupPreDefinedLocations()
        }
        .onDisappear {
            vetService.stopUpdating()
        }
        .sheet(item: $selectedLocation) { location in
            NavigationStack {
                ScrollView {
                    MapItem(location: location)
                        .frame(maxWidth: .infinity)
                        .padding(.spacing20)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            selectedLocation = nil
                        } label: {
                            Label(SharedStrings.resource("Close"), systemImage: "xmark")
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Helper Views
private extension FindVet {

    var mapView: some View {
        Map(
            position: $userLocation,
            selection: $selectedLocation
        ) {
            ForEach(searchedLocations) { location in
                Marker(
                    location.name,
                    systemImage: "pawprint.circle.fill",
                    coordinate: location.coordinate
                )
                .tint(.accent)
                .tag(location)
            }
            UserAnnotation()
        }
        .mapControls {
            MapPitchToggle()
            MapUserLocationButton()
        }
        .searchable(text: $searchText, isPresented: $isSearching)
        .onSubmit(of: .search) {
            searchedLocations.removeAll()
            searchLocations()
            isSearching = false
        }
    }

    @ContentBuilder var locationNotAvailable: some View {
        if mapViewStatus == .locationNotAllowed && searchedLocations.isEmpty {
            ContentUnavailableView {
                Label {
                    Text(SharedStrings.findVetErrorTitle)
                } icon: {
                    Image(systemName: "mappin.slash.circle")
                }
            } description: {
                Text(SharedStrings.locationAlertContext)
            } actions: {
                SettingsButton()
            }
        }
    }
}

// MARK: - Helper Functions
private extension FindVet {

    @MainActor
    func setupPreDefinedLocations() async {
        self.mapViewStatus = vetService.setViewStatus()
        self.userLocation = vetService.findUserLocation()

        self.searchedLocations = await vetService.searchLocations(
            with: searchText,
            near: userLocation
        )
    }

    func searchLocations() {
        Task { @MainActor in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard query.isEmpty == false else {
                self.searchedLocations = []
                return
            }
            self.searchedLocations = await vetService.searchLocations(
                with: query,
                near: userLocation
            )
        }
    }
}

#if DEBUG
#Preview("English") {
    @Previewable @State var searchText = "Vet"

    FindVet(service: VetServiceImplementation(), searchText: searchText)
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Turkish") {
    @Previewable @State var searchText = "Veteriner"

    FindVet(service: VetServiceImplementation(), searchText: searchText)
        .environment(\.locale, .init(identifier: "tr"))
}
#endif
