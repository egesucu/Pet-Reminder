//
//  VetViewModelProtocol.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.11.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import MapKit
import CoreLocation
import SwiftUI
import Observation

protocol VetViewModelProtocol: Observable {
    var userLocation: MapCameraPosition { get set }
    var searchText: String { get set }
    var searchedLocations: [Pin] { get set }
    var selectedLocation: Pin? { get set }
    var mapViewStatus: MapViewStatus { get set }
    
    func requestMap() async
    func updateAuthenticationStatus() async
    func clearPreviousSearches() async
    func searchPins() async
}
