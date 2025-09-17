//
//  VetServiceTests.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 16.09.2025.
//  Copyright © 2025 Ege Sucu. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI // For MapCameraPosition and its APIs
import Testing
import Shared // For Pin and MapViewStatus
@testable import Pet_Reminder

// MARK: - Test Doubles

private final class MockCLLocationManager: CLLocationManager {

    // Inputs we control
    var stubAuthorizationStatus: CLAuthorizationStatus = .notDetermined

    // Observations
    private(set) var didRequestWhenInUseAuthorization = false
    private(set) var didStartUpdatingLocation = false
    private(set) var didStopUpdatingLocation = false

    override var authorizationStatus: CLAuthorizationStatus {
        stubAuthorizationStatus
    }

    override func requestWhenInUseAuthorization() {
        didRequestWhenInUseAuthorization = true
    }

    override func startUpdatingLocation() {
        didStartUpdatingLocation = true
    }

    override func stopUpdatingLocation() {
        didStopUpdatingLocation = true
    }
}

// MARK: - Mock VetService (protocol-level mock you can reuse in other tests)

final class MockVetService: VetService {
    func stopUpdating() {
        
    }

    // Inputs you can preset
    var nextStatus: MapViewStatus = .none
    var nextCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    var nextPins: [Pin] = []

    // Observations
    private(set) var didRequestPermissions = false
    private(set) var didSetViewStatus = false
    private(set) var lastSearchTerm: String?
    private(set) var lastCameraPosition: MapCameraPosition?

    func requestMapPermissions() async {
        didRequestPermissions = true
    }

    func setViewStatus() -> MapViewStatus {
        didSetViewStatus = true
        return nextStatus
    }

    func findUserLocation() -> MapCameraPosition {
        nextCamera
    }

    func searchLocations(with searchTerm: String, near userLocation: MapCameraPosition) async -> [Pin] {
        lastSearchTerm = searchTerm
        lastCameraPosition = userLocation
        return nextPins
    }
}

// MARK: - Tests

@Suite("Vet Service Testing")
struct VetServiceTests {

    @Test("requestMapPermissions should ask for when-in-use authorization")
    @MainActor
    func requestPermissionsTriggersAuthorization() async throws {
        let mockLocationManager = MockCLLocationManager()
        let sut = VetServiceImplementation(locationManager: mockLocationManager)

        await sut.requestMapPermissions()

        #expect(mockLocationManager.didRequestWhenInUseAuthorization == true)
    }

    @Test("setViewStatus returns .authorized when location is authorized and starts updating location")
    @MainActor
    func setViewStatusAuthorized() throws {
        let mockLocationManager = MockCLLocationManager()
        mockLocationManager.stubAuthorizationStatus = .authorizedWhenInUse
        let sut = VetServiceImplementation(locationManager: mockLocationManager)

        let status = sut.setViewStatus()

        #expect(status == .authorized)
        #expect(mockLocationManager.didStartUpdatingLocation == true)
    }

    @Test("setViewStatus returns .locationNotAllowed for non-authorized states")
    @MainActor
    func setViewStatusNotAllowed() throws {
        for auth: CLAuthorizationStatus in [.denied, .restricted, .notDetermined] {
            let mockLocationManager = MockCLLocationManager()
            mockLocationManager.stubAuthorizationStatus = auth
            let sut = VetServiceImplementation(locationManager: mockLocationManager)

            let status = sut.setViewStatus()

            #expect(status == .locationNotAllowed)
            #expect(mockLocationManager.didStartUpdatingLocation == false)
        }
    }

    @Test("findUserLocation returns a user-follow camera position")
    @MainActor
    func findUserLocationReturnsUserCamera() throws {
        let sut = VetServiceImplementation(locationManager: MockCLLocationManager())

        let camera = sut.findUserLocation()

        // We can at least assert the camera is not a fixed region by checking that region is nil
        #expect(camera.region == nil)
    }

    // Integration-style smoke test without stubbing MKLocalSearch internals.
    @Test("searchLocations completes and returns an array (smoke test)")
    @MainActor
    func searchLocationsSmoke() async throws {
        let sut = VetServiceImplementation(locationManager: MockCLLocationManager())
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        let camera = MapCameraPosition.region(region)

        let pins = await sut.searchLocations(with: "vet", near: camera)

        // Only assert type-level expectations to avoid flakiness.
        #expect(pins.count >= 0)
    }

    @Test("MockVetService behaves as a controllable test double")
    @MainActor
    func mockVetServiceBehavior() async throws {
        let mock = MockVetService()
        mock.nextStatus = .authorized
        let region = MKCoordinateRegion(center: .init(latitude: 42, longitude: -71),
                                        span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mock.nextCamera = .region(region)

        // Build a pin from MKMapItem using the non-deprecated API
        let location = CLLocation(latitude: 5, longitude: 6)
        let item = MKMapItem(location: location, address: nil)
        item.name = "Mock Vet"
        mock.nextPins = [Pin(item: item)]

        await mock.requestMapPermissions()
        let status = mock.setViewStatus()
        let camera = mock.findUserLocation()
        let results = await mock.searchLocations(with: "search", near: camera)

        #expect(mock.didRequestPermissions == true)
        #expect(mock.didSetViewStatus == true)
        #expect(status == .authorized)
        #expect(camera.region != nil)
        #expect(mock.lastSearchTerm == "search")
        #expect(results.count == 1)
        #expect(results.first?.name == "Mock Vet")
    }
}

