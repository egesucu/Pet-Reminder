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

struct FindVet: View {

    @State private var vetService = VetServiceImplementation()

    @State private var searchText = String(localized: .defaultVetText)

    @State private var userLocation: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    @State private var searchedLocations: [Pin] = []
    @State private var selectedLocation: Pin?
    @State private var mapViewStatus: MapViewStatus = .none

    init(searchText: String = String(localized: .defaultVetText)) {
        self._searchText = State(initialValue: searchText)
    }

    var body: some View {
        NavigationStack {
            mapView
        }
        .overlay(locationNotAvailable)
        .task {
            await vetService.requestMapPermissions()
            await setupPreDefinedLocations()
        }
        .onDisappear {
            vetService.stopUpdating()
        }
        .sheet(item: $selectedLocation) { location in
            MapItem(location: location)
                .presentationDetents([.fraction(0.2)])
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
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            searchedLocations.removeAll()
            searchLocations()
        }
    }
    
    @ViewBuilder var locationNotAvailable: some View {
        if mapViewStatus == .locationNotAllowed && searchedLocations.isEmpty {
            ContentUnavailableView {
                Label {
                    Text(.findVetErrorTitle)
                } icon: {
                    Image(systemName: "mappin.slash.circle")
                }
            } description: {
                Text(.locationAlertContext)
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

    FindVet(searchText: searchText)
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Turkish") {
    @Previewable @State var searchText = "Veteriner"

    FindVet(searchText: searchText)
        .environment(\.locale, .init(identifier: "tr"))
}
#endif
