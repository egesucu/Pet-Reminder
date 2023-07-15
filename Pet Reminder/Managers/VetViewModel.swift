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
import Observation

@Observable
class VetViewModel: NSObject {

    var userLocation = CLLocation()
    var region = MKCoordinateRegion()
    var permissionDenied = false
    var searchText = String(localized: "default_vet_text")

    var locationManager = CLLocationManager()

    func askLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        getUserLocation()
    }

    func getUserLocation() {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            if let location = locationManager.location {
                userLocation = location
                setRegion()
            }
        }
    }

    func setRegion() {
        self.region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        )
    }

    func searchPins(searchText: String, completion: @escaping (Result<[Pin], Error>) -> Void) {
        var pins = [Pin]()
        let searchRequest = MKLocalSearch.Request()

        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region

        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { response, error in
            if let error = error {
                completion(.failure(error))
            } else if let response = response {
                for item in response.mapItems {
                    let pin = Pin(item: item)
                    pins.append(pin)
                }
                completion(.success(pins))
            }
        }
    }

}
