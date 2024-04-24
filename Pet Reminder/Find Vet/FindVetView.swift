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

struct FindVetView: View {

    @State private var viewModel = VetViewModel()
    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    var body: some View {
        NavigationStack {
            mapView
        }
        .navigationTitle(Text("find_vet_title"))
        .overlay {
            if viewModel.mapViewStatus == .locationNotAllowed {
                ContentUnavailableView {
                    Label("find_vet_error_title", systemImage: SFSymbols.locationAuthError)
                } description: {
                    Text("location_alert_context")
                } actions: {
                    ESSettingsButton()
                }
            }
        }
        .task {
            await viewModel.requestMap()
        }
        .onSubmit(of: .search) {
            Task {
                await viewModel.searchPins()
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
                    systemImage: SFSymbols.pawprintCircleFill,
                    coordinate: location.coordinate
                )
                .tint(tintColor)
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
        .onSubmit(of: .search, searchPins)
        .disableAutocorrection(true)
    }

    func searchPins() {
        Task {
            viewModel.searchPins
        }
    }
}

#Preview {
    FindVetView()
}

