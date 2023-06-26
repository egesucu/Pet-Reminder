//
//  ViewExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

extension View {

    func openURLWithMap(latitude: CGFloat, longitude: CGFloat, application: MapApplication) {
        switch application {
            case .google:
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
            case .apple:
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let placemark = MKPlacemark(coordinate: coordinate)
                let item = MKMapItem(placemark: placemark)
                item.openInMaps()
            case .yandex:
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
}

extension VetViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        askLocationPermission()
    }
}
