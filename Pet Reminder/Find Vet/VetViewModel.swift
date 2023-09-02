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
    var showAlert = false
    var searchedLocations: [Pin] = []
    var locationManager = CLLocationManager()
    var selectedItem: Pin = Pin(item: .init())

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    @Sendable
    func getUserLocation() async {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            if let location = locationManager.location {
                userLocation = location
                await setRegion()
            }
        }
    }

    private func setRegion() async {
        self.region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        )
    }

    func setRegion(item: Pin) async {
        self.region = MKCoordinateRegion(
            center: item.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        )
    }

    func searchPins() async {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region

        let localSearch = MKLocalSearch(request: searchRequest)

        do {
            let response = try await localSearch.start()
            for item in response.mapItems {
                let pin = Pin(item: item)
                searchedLocations.append(pin)
            }
        } catch let error {
            print(error)
        }
    }

    func openAppSettings() async {
        if let bundle = Bundle.main.bundleIdentifier,
           let appSettings = await URL(string: UIApplication.openSettingsURLString + bundle) {
            await UIApplication.shared.open(appSettings)
        }
    }
}
// MARK: - CLLocationManagerDelegate
extension VetViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.permissionDenied = false
            Task {
                await getUserLocation()
            }
        } else {
            self.permissionDenied = true
        }
    }
}