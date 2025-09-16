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
    /// Requests the user's permission to access location while the app is in use.
    ///
    /// This method triggers the system authorization prompt, if needed. It does not suspend
    /// until the user responds; instead, you should query authorization later (e.g., via `setViewStatus()`).
    ///
    /// - Important: Intended to be called from UI flow (e.g., on first launch or when access is required).
    /// - SeeAlso: `setViewStatus()` to interpret the current authorization state.
    func requestMapPermissions() async

    /// Evaluates the current location authorization and returns an appropriate map view status.
    ///
    /// - Returns: A `MapViewStatus` value reflecting whether location is authorized, not determined,
    ///            or disallowed. Use this to drive UI (e.g., overlays or error states).
    /// - Note: When authorized, you may begin location updates and show user location on the map.
    func setViewStatus() -> MapViewStatus

    /// Produces a camera position centered on the user's current location.
    ///
    /// Use the returned `MapCameraPosition` to configure SwiftUI's `Map` view so it follows the user.
    /// If heading-follow is supported, the camera may follow the device heading.
    ///
    /// - Returns: A `MapCameraPosition` configured to follow the user's location, with a sensible fallback.
    func findUserLocation() -> MapCameraPosition

    /// Performs a local map search near a given camera region and returns matching pins.
    ///
    /// This uses `MKLocalSearch` with the provided `searchTerm` and, if available, scopes the search
    /// to the region contained in `userLocation`. The results are transformed into `Pin` models.
    ///
    /// - Parameters:
    ///   - searchTerm: The natural language query (e.g., "vet", "animal hospital").
    ///   - userLocation: A `MapCameraPosition` whose region, if present, is used to constrain the search.
    /// - Returns: An array of `Pin` representing search results. Returns an empty array if the search fails.
    /// - Throws: This method itself does not throw; any internal search errors are caught and logged.
    func searchLocations(with searchTerm: String, near userLocation: MapCameraPosition) async -> [Pin]
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
            // Start tracking user location here
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

}
