//
//  VetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 24.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import CoreLocation
import MapKit
import Observation
import OSLog
import SwiftUI

@Observable
class VetViewModel: NSObject, VetViewModelProtocol {

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
      .vet
      .info("Location Auth Status: \(self.mapViewStatus.rawValue)")
  }

  func updateAuthenticationStatus() async {
    locationManager.requestWhenInUseAuthorization()
    mapViewStatus = switch locationManager.authorizationStatus {
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

  func clearPreviousSearches() async {
    await MainActor.run {
      searchedLocations.removeAll()
    }
  }

  func searchPins() async {
    await clearPreviousSearches()

    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = searchText
    if let region = userLocation.region {
      searchRequest.region = region
    }

    let localSearch = MKLocalSearch(request: searchRequest)

    do {
      let response = try await localSearch.start()
      await MainActor.run {
        for mapItem in response.mapItems {
          self.searchedLocations.append(Pin(item: mapItem))
        }
        userLocation = .userLocation(fallback: .automatic)
      }
    } catch let error {
      Logger
        .vet
        .error("\(error)")
    }
  }
}
