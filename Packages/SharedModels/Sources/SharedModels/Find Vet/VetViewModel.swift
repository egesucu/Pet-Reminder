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

@MainActor
@Observable
public class VetViewModel {

    public var userLocation: MapCameraPosition = .userLocation(fallback: .automatic)
    public var searchText = String(localized: "default_vet_text")
    public var searchedLocations: [Pin] = []
    public var locationManager = CLLocationManager()
    public var selectedLocation: Pin?
    public var mapViewStatus: MapViewStatus = .none
    
    public init() { }
    
    public func requestMap() async {
        await updateAuthenticationStatus()
        Logger.vet.info("Location Auth Status: \(self.mapViewStatus.rawValue)")
    }
    
    public func updateAuthenticationStatus() async {
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
            await MainActor.run {
                userLocation = .userLocation(fallback: .automatic)
            }
            await searchPins()
        }
    }
    
    public func clearPreviousSearches() async {
        await MainActor.run {
            searchedLocations.removeAll()
        }
    }
    
    public func searchPins() async {
        await clearPreviousSearches()
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        if let region = userLocation.region {
            searchRequest.region = region
        }
        
        let localSearch = MKLocalSearch(request: searchRequest)
        
        Task {
            let response = try await localSearch.start()
            await processSearchResponse(response)
        }
    }
    
    @MainActor
    private func processSearchResponse(_ response: MKLocalSearch.Response) async {
        await MainActor.run {
            response.mapItems.forEach {
                self.searchedLocations.append(Pin(item: $0))
            }
            userLocation = .userLocation(fallback: .automatic)
        }
    }
}

extension MKLocalSearch.Response: @unchecked @retroactive Sendable {}
