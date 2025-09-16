//
//  VetService.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 24.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import MapKit
import CoreLocation
import SwiftUI
import OSLog
import Observation
import Shared

protocol VetService {
    func requestMapPermissions() async
    func setViewStatus() -> MapViewStatus
    func findUserLocation() -> MapCameraPosition
    func searchLocations(with searchTerm: String, near userLocation: MapCameraPosition) async -> [Pin]
    // New: allow stopping updates when the view disappears
    func stopUpdating()
}

@Observable
class VetServiceImplementation: VetService {

    private let locationManager: CLLocationManager

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    @MainActor deinit {
        locationManager.stopUpdatingLocation()
    }

    func requestMapPermissions() async {
        locationManager.requestWhenInUseAuthorization()
    }

    func setViewStatus() -> MapViewStatus {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            return .authorized
        default:
            return .locationNotAllowed
        }
    }

    func findUserLocation() -> MapCameraPosition {
        .userLocation(
            followsHeading: true,
            fallback: .automatic
        )
    }

    func searchLocations(with searchTerm: String, near userLocation: MapCameraPosition) async -> [Pin] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchTerm
        if let region = userLocation.region {
            searchRequest.region = region
        }

        let localSearch = MKLocalSearch(request: searchRequest)

        do {
            let response = try await localSearch.start()
            return processSearchResponse(response)
        } catch {
            Logger.vet.error("Local Search Failed: \(error.localizedDescription)")
            return []
        }
    }

    private func processSearchResponse(_ response: MKLocalSearch.Response) -> [Pin] {
        var pins: [Pin] = []
        response.mapItems.forEach {
            pins.append(Pin(item: $0))
        }
        return pins
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}
