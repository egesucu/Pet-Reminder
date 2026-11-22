//
//  FindVet.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit
import Shared
import SharedUI

@MainActor
public struct FindVet: View {

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let vetService: any VetService

    @State private var searchText: String
    @State private var isSearching = false
    @State private var submittedQuery: String?
    @State private var searchRequestID = 0
    @State private var isLoadingResults = true

    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchedLocations: [Pin] = []
    @State private var selectedLocationID: Pin.ID?
    @State private var mapViewStatus: MapViewStatus = .none

    public init(service: any VetService, searchText: String = String(localized: SharedStrings.defaultVetText)) {
        self.vetService = service
        self._searchText = State(initialValue: searchText)
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if #available(iOS 27.1, *),
                   let fold = geometry.reservedRegions(kind: .division).first(where: \.isActive) {
                    let sideBySide = fold.frame.height > fold.frame.width
                    ArrangementView {
                        mapView
                            .ignoresSafeArea(.container, edges: sideBySide ? .bottom : [])
                    } secondary: {
                        resultsView(sideBySide: sideBySide)
                    }
                    .arrangementViewStyle(.split)
                } else if horizontalSizeClass == .regular || verticalSizeClass == .compact {
                    let mapWidth = geometry.size.width / 2
                    HStack(spacing: 0) {
                        mapView
                            .ignoresSafeArea(.container, edges: horizontalSizeClass == .regular ? .bottom : [])
                            .frame(width: mapWidth)
                        resultsView(sideBySide: true)
                    }
                } else {
                    VStack(spacing: 0) {
                        mapView.frame(height: geometry.size.height * (dynamicTypeSize.isAccessibilitySize ? 0.35 : 0.58))
                        resultsView(sideBySide: false, compactRows: true)
                    }
                }
            }
            .background {
                Color(uiColor: .systemGray5)
                    .ignoresSafeArea()
            }
            .navigationTitle(Text(SharedStrings.findVetTitle))
            .toolbarBackground(Color(uiColor: .systemGray5), for: .navigationBar)
            .searchable(
                text: $searchText,
                isPresented: $isSearching,
                placement: verticalSizeClass == .compact ? .navigationBarDrawer(displayMode: .always) : .automatic
            )
            .onSubmit(of: .search) {
                submittedQuery = searchText
                searchRequestID += 1
                isSearching = false
            }
        }
        .task(id: searchRequestID) {
            await searchLocations()
        }
        .onDisappear {
            vetService.stopUpdating()
        }
    }
}

private extension FindVet {

    var mapView: some View {
        Map(position: $mapPosition, selection: $selectedLocationID) {
            ForEach(searchedLocations) { location in
                Marker(
                    location.name,
                    systemImage: "pawprint.circle.fill",
                    coordinate: location.coordinate
                )
                .tint(.accent)
                .tag(location.id)
            }
            UserAnnotation()
        }
        .mapControls {
            MapPitchToggle()
            MapUserLocationButton()
        }
        .onMapCameraChange { context in
            if mapPosition.positionedByUser || mapPosition.followsUserLocation {
                visibleRegion = context.region
            }

            if mapPosition.followsUserLocation, mapViewStatus == .locationNotAllowed,
               vetService.setViewStatus() == .authorized {
                mapViewStatus = .authorized
                if submittedQuery == nil {
                    searchRequestID += 1
                }
            }
        }
        .onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { _ in
            if !isSearching, mapPosition.rect != nil, !mapPosition.positionedByUser {
                fitMapToResults()
            }
        }
        .clipped()
    }

    @ViewBuilder func resultsView(sideBySide: Bool, compactRows: Bool = false) -> some View {
        if isLoadingResults {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if searchedLocations.isEmpty {
            if mapViewStatus == .locationNotAllowed {
                locationNotAvailable
            } else {
                ContentUnavailableView.search(text: submittedQuery ?? searchText)
            }
        } else {
            ScrollViewReader { proxy in
                Group {
                    if sideBySide {
                        ScrollView {
                            LazyVStack(spacing: .spacing8) {
                                ForEach(searchedLocations) { location in
                                    let isSelected = selectedLocationID == location.id
                                    let shape = RoundedRectangle(cornerRadius: 16)

                                    MapItem(location: location, isSelected: isSelected, showsCardStyle: true)
                                        .padding(.horizontal, .spacing16)
                                        .padding(.vertical, .spacing8)
                                        .background(Color(uiColor: .systemGray6), in: shape)
                                        .overlay {
                                            shape.strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                                                .allowsHitTesting(false)
                                        }
                                        .id(location.id)
                                }
                            }
                            .padding(.spacing16)
                        }
                    } else {
                        List(searchedLocations) { location in
                            let isSelected = selectedLocationID == location.id

                            MapItem(location: location, isSelected: isSelected)
                                .listRowInsets(.vertical, compactRows ? 4 : nil)
                                .listRowBackground(isSelected ? Color.accentColor.opacity(0.14) : nil)
                                .id(location.id)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .onChange(of: selectedLocationID, initial: true) { _, locationID in
                    guard let locationID else { return }
                    withAnimation(reduceMotion ? nil : .default) {
                        proxy.scrollTo(locationID, anchor: .center)
                    }
                }
            }
        }
    }

    var locationNotAvailable: some View {
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

    func searchLocations() async {
        isLoadingResults = true
        selectedLocationID = nil
        searchedLocations = []

        if searchRequestID == 0 {
            await vetService.requestMapPermissions()
            guard !Task.isCancelled else { return }
            mapPosition = vetService.findUserLocation()
        }
        mapViewStatus = vetService.setViewStatus()

        let query = (submittedQuery ?? searchText).trimmingCharacters(in: .whitespacesAndNewlines)
        var locations: [Pin] = []
        if !query.isEmpty {
            let searchPosition = visibleRegion.map { MapCameraPosition.region($0) } ?? mapPosition
            locations = await vetService.searchLocations(with: query, near: searchPosition)
        }
        guard !Task.isCancelled else { return }

        var seenIDs: Set<Pin.ID> = []
        searchedLocations = locations.filter { seenIDs.insert($0.id).inserted }
        fitMapToResults()
        isLoadingResults = false
    }

    func fitMapToResults() {
        let bounds = searchedLocations.reduce(MKMapRect.null) { bounds, location in
            let point = MKMapPoint(location.coordinate)
            return bounds.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        guard let firstLocation = searchedLocations.first else { return }

        let minimumPadding = 400 * MKMapPointsPerMeterAtLatitude(firstLocation.latitude)
        let paddingRatio = verticalSizeClass == .compact ? 0.30 : 0.15
        mapPosition = .rect(bounds.insetBy(
            dx: -max(bounds.width * paddingRatio, minimumPadding),
            dy: -max(bounds.height * paddingRatio, minimumPadding)
        ))
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
