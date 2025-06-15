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

    @State private var viewModel = VetViewModel()
    @State private var searchText = String(localized: .defaultVetText)
    
    init() {}
    
    init(searchText: State<String>) {
        self._searchText = searchText
    }

    var body: some View {
        NavigationStack {
            mapView
        }
        .overlay {
            if viewModel.mapViewStatus == .locationNotAllowed {
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
            await viewModel.requestLocation()
            await viewModel.requestMap()
            try? await viewModel.searchPins(text: searchText)
        }
        .sheet(item: $viewModel.selectedLocation, onDismiss: {
            withAnimation {
                viewModel.selectedLocation = nil
            }
        }, content: { location in
            MapItemView(location: location)
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
                .padding(.horizontal)
        })
    }

    private var mapView: some View {
        Map(
            position: $viewModel.userLocation,
            selection: $viewModel.selectedLocation
        ) {
            ForEach(viewModel.searchedLocations) { location in
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
            Task {
                do {
                    try await viewModel.searchPins(text: searchText)
                } catch let error {
                    Logger.vet.error("Error setting user location: \(error.localizedDescription)")
                }
            }
        }
        .disableAutocorrection(true)
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
