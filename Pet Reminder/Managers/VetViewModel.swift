//
//  VetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 24.02.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import MapKit
import CoreLocation
import SwiftUI

class VetViewModel: NSObject, ObservableObject {

    @Published var userLocation = CLLocation()
    @Published var region = MKCoordinateRegion()
    @Published var permissionDenied = false
    @Published var searchText: String = Strings.defaultVetText

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
        self.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
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
                    pins.append(Pin(item: item))
                }
                completion(.success(pins))
            }
        }
    }

}
