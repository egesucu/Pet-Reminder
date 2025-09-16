//
//  FindVetView.swift
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
import SFSafeSymbols

struct FindVetView: View {

    @State private var vetService = VetServiceImplementation(
        locationManager: .init()
    )

    @State private var searchText = String(localized: .defaultVetText)

    @State private var userLocation: MapCameraPosition = .userLocation(
        fallback: .automatic
    )
    @State private var searchedLocations: [Pin] = []
    @State private var selectedLocation: Pin?
    @State private var mapViewStatus: MapViewStatus = .none

    init(
        searchText: State<String> = .init(
            initialValue: String(
                localized: .defaultVetText
            )
        )
    ) {
        self._searchText = searchText
    }

    var body: some View {
        NavigationStack {
            mapView
        }
        .overlay {
            if mapViewStatus == .locationNotAllowed {
                ContentUnavailableView {
                    Label {
                        Text(.findVetErrorTitle)
                    } icon: {
                        Image(systemSymbol: SFSymbol.mappinSlashCircle)
                    }
                } description: {
                    Text(.locationAlertContext)
                } actions: {
                    SettingsButton()
                }
            }
        }
        .task {
            await vetService.requestMapPermissions()
            self.mapViewStatus = vetService.setViewStatus()
            self.userLocation = vetService.findUserLocation()

            self.searchedLocations = await vetService.searchLocations(
                with: searchText,
                near: userLocation
            )
        }
        .sheet(item: $selectedLocation) { location in
            MapItemView(location: location)
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
                .padding(.horizontal)
        }
    }

    private var mapView: some View {
        Map(
            position: $userLocation,
            selection: $selectedLocation
        ) {
            ForEach(searchedLocations) { location in
                Marker(
                    location.name,
                    systemImage: SFSymbol.pawprintCircleFill.rawValue,
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
            MapCompass()
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            searchedLocations.removeAll()
            searchLocations()
        }
        .disableAutocorrection(true)
    }

    private func searchLocations() {
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

#Preview("English") {
    @Previewable @State var searchText = "Vet"

    FindVetView(searchText: _searchText)
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Turkish") {
    @Previewable @State var searchText = "Veteriner"

    FindVetView(searchText: _searchText)
        .environment(\.locale, .init(identifier: "tr"))
}
