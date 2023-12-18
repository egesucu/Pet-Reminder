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

class MockVetViewModel: VetViewModelProtocol {
    
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
        await MainActor.run {
            self.searchedLocations.removeAll()
        }
    }
    
    func searchPins() async {
        await clearPreviousSearches()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            self.searchedLocations = [
                Pin(
                    item: MKMapItem(
                        placemark: MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: 41.1114,
                                longitude: 29.1790
                            )
                        )
                    )
                ),
                Pin(
                    item: MKMapItem(
                        placemark: MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: 41.0681,
                                longitude: 29.0693
                            )
                        )
                    )
                ),
                Pin(
                    item: MKMapItem(
                        placemark: MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: 41.0200,
                                longitude: 29.3439
                            )
                        )
                    )
                ),
                Pin(
                    item: MKMapItem(
                        placemark: MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: 41.0663,
                                longitude: 28.9010
                            )
                        )
                    )
                ),
                Pin(
                    item: MKMapItem(
                        placemark: MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: 41.2085,
                                longitude: 29.0942
                            )
                        )
                    )
                )
            ]
        }
    }
}
