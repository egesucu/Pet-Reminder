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
    
    init() {
        viewModel.searchText = String(localized: "default_vet_text")
    }

    var body: some View {
        NavigationStack {
            mapView
                .navigationTitle(Text("find_vet_title"))
                .navigationBarTitleTextColor(.accent)
        }
        .overlay {
            if viewModel.mapViewStatus == .locationNotAllowed {
                ContentUnavailableView {
                    Label {
                        Text("find_vet_error_title")
                    } icon: {
                        Image(systemSymbol: SFSymbol.mappinSlashCircle)
                    }
                } description: {
                    Text("location_alert_context")
                } actions: {
                    SettingsButton()
                }
            }
        }
        .task {
            await viewModel.requestLocation()
            await viewModel.requestMap()
            if viewModel.searchedLocations.isEmpty {
                try? await viewModel.searchPins()
            }
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
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            Task {
                do {
                    try await viewModel.searchPins()
                } catch let error {
                    Logger.vet.error("Error setting user location: \(error.localizedDescription)")
                }
            }
        }
        .disableAutocorrection(true)
    }
}

#Preview("English") {
    FindVetView()
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Turkish") {
    FindVetView()
        .environment(\.locale, .init(identifier: "tr"))
}
