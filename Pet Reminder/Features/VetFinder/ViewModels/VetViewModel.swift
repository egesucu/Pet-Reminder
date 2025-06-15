//
//  VetViewModel.swift
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

@MainActor
@Observable
class VetViewModel {

    var userLocation: MapCameraPosition = .userLocation(fallback: .automatic)
    var searchText = ""
    var searchedLocations: [Pin] = []
    var locationManager = CLLocationManager()
    var selectedLocation: Pin?
    var mapViewStatus: MapViewStatus = .none
    
    init() { }
    
    func requestMap() async {
        await updateAuthenticationStatus()
        Logger.vet.info("Location Auth Status: \(self.mapViewStatus.rawValue)")
    }
    
    @MainActor
    func requestLocation() async {
        locationManager.requestWhenInUseAuthorization()
        await updateAuthenticationStatus()
    }
    
    @MainActor
    func updateAuthenticationStatus() async {
        self.mapViewStatus = switch locationManager.authorizationStatus {
        case .notDetermined:
                .none
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
                .authorized
        default:
                .locationNotAllowed
        }
        
        if mapViewStatus == .authorized {
            await setUserLocation()
        }
    }
    
    @MainActor
    func setUserLocation() async {
        locationManager.startUpdatingLocation()
        userLocation = .userLocation(fallback: .automatic)
        do {
            try await searchPins()
        } catch let error {
            Logger.vet.error("Error setting user location: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func clearPreviousSearches() async {
        searchedLocations.removeAll()
    }
    
    @MainActor
    func searchPins() async throws {
        await clearPreviousSearches()
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        if let region = userLocation.region {
            searchRequest.region = region
        }
        
        let localSearch = MKLocalSearch(request: searchRequest)
        
        Task {
            do {
                let response = try await localSearch.start()
                await processSearchResponse(response)
            } catch let error {
                throw error
            }
        }
    }
    
    @MainActor
    private func processSearchResponse(_ response: MKLocalSearch.Response) async {
        response.mapItems.forEach {
            self.searchedLocations.append(Pin(item: $0))
        }
        userLocation = .userLocation(fallback: .automatic)
    }
}

extension MKLocalSearch.Response: @unchecked @retroactive Sendable {
}
