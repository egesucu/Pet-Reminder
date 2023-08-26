//
//  ViewExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
// swiftlint:disable switch_case_alignment
import SwiftUI
import MapKit
import CoreLocation

extension View {

    func printVariable(_ variables: Any...) -> some View {
        for variable in variables { print(variable) }
        return EmptyView()
    }

    func openURLWithMap(latitude: CGFloat, longitude: CGFloat, application: MapApplication) {
        switch application {
            case .google:
                handleGoogleMaps(latitude: latitude, longitude: longitude)
            case .apple:
                handleAppleMaps(latitude: latitude, longitude: longitude)
            case .yandex:
                handleYandexMap(latitude: latitude, longitude: longitude)
        }
    }

    private func handleGoogleMaps(latitude: CGFloat, longitude: CGFloat) {
        guard let deeplink = URLDefinitions.googleMapsDeeplinkURL else { return }
        if UIApplication.shared.canOpenURL(deeplink) {
            let url = URL(string: String(format: URLDefinitions.googleMapsLocationString, latitude, longitude))
            if let url {
                UIApplication.shared.open(url)
            }
        } else {
            if let url = URLDefinitions.googleMapsAppStoreURL {
                UIApplication.shared.open(url)
            }
        }
    }

    private func handleAppleMaps(latitude: CGFloat, longitude: CGFloat) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.openInMaps()
    }

    private func handleYandexMap(latitude: CGFloat, longitude: CGFloat) {
        guard let deeplink = URLDefinitions.yandexMapsDeeplinkURL else { return }
        if UIApplication.shared.canOpenURL(deeplink) {
            let url = URL(string: String(format: URLDefinitions.yandexMapsLocationString, latitude, longitude))
            if let url {
                UIApplication.shared.open(url)
            }
        } else {
            if let url = URLDefinitions.yandexMapsAppStoreURL {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension VetViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        askLocationPermission()
    }
}
// swiftlint:enable switch_case_alignment

extension DateComponents {
    static func generateRandomDateComponent() -> Self {
        DateComponents(
            year: Int.random(in: 2018...2023),
            month: Int.random(in: 0...12),
            day: Int.random(in: 0...30),
            hour: Int.random(in: 0...23),
            minute: Int.random(in: 0...59),
            second: Int.random(in: 0...59)
        )
    }
}
