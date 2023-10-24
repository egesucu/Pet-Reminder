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

@Observable
class VetViewModel: NSObject {

    var userLocation: MapCameraPosition = .userLocation(fallback: .automatic)
    var searchText = String(localized: "default_vet_text")
    var searchedLocations: [Pin] = []
    var locationManager = CLLocationManager()
    var selectedLocation: Pin?
    var mapViewStatus: MapViewStatus = .none
    
    @Sendable
    func requestMap() async {
        await updateAuthenticationStatus()
        Logger
            .viewCycle
            .info("Location Auth Status: \(self.mapViewStatus.rawValue)")
    }
    
    func updateAuthenticationStatus() async {
        locationManager.requestWhenInUseAuthorization()
        self.mapViewStatus = switch locationManager.authorizationStatus {
        case .notDetermined:
                .none
        case .denied, .restricted:
                .locationNotAllowed
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
                .authorized
        @unknown default:
                .none
        }
        
        if mapViewStatus == .authorized {
            await searchPins()
        }
    }

    func clearPreviousSearches() {
        DispatchQueue.main.async {
            self.searchedLocations.removeAll()
        }
    }

    func searchPins() async {
        clearPreviousSearches()

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        if let region = userLocation.region {
            searchRequest.region = region
        }

        let localSearch = MKLocalSearch(request: searchRequest)

        do {
            let response = try await localSearch.start()
            await MainActor.run {
                response.mapItems.forEach {
                    self.searchedLocations.append(Pin(item: $0))
                }
                userLocation = .userLocation(fallback: .automatic)
            }
        } catch let error {
            Logger
                .viewCycle
                .error("\(error)")
        }
        
    }
}
