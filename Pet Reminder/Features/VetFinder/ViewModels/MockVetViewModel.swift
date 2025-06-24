//
//  MockVetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation
import Shared

class MockVetViewModel: @unchecked Sendable {

    var userLocation: MapCameraPosition = .automatic

    var searchText: String = ""

    var searchedLocations: [Pin] = []

    var selectedLocation: Pin?

    var mapViewStatus: MapViewStatus = .none

    func requestMap() async {
        await updateAuthenticationStatus()
    }

    func updateAuthenticationStatus() async {
        self.mapViewStatus = .authorized
    }

    func clearPreviousSearches() async {
        searchedLocations.removeAll()
    }

    func searchPins() async {
        await clearPreviousSearches()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        self.searchedLocations = [
            Pin(
                item: MKMapItem(
                    location: .init(latitude: 41.1114, longitude: 29.1790),
                    address: nil
                )
            ),
            Pin(
                item: MKMapItem(
                    location: .init(latitude: 41.0681, longitude: 29.0693),
                    address: nil
                )
            ),
            Pin(
                item: MKMapItem(
                    location: .init(latitude: 41.0200, longitude: 29.3439),
                    address: nil
                )
            ),
            Pin(
                item: MKMapItem(
                    location: .init(latitude: 41.0663, longitude: 28.9010),
                    address: nil
                )
            ),
            Pin(
                item: MKMapItem(
                    location: .init(latitude: 41.2085, longitude: 29.0942),
                    address: nil
                )
            )
        ]
    }
}
