//
//  ViewExtensions.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 30.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
import SwiftUI
import MapKit
import CoreLocation

public extension View {

    func openURLWithMap(location: Pin, application: MapApplication) {
        switch application {
        case .google:
            handleGoogleMaps(location: location)
        case .apple:
            handleAppleMaps(location: location)
        case .yandex:
            handleYandexMap(location: location)
        }
    }

    private func handleGoogleMaps(location: Pin) {
        guard let deeplink = URLDefinitions.googleMapsDeeplinkURL else { return }
        if UIApplication.shared.canOpenURL(deeplink) {
            let content = URLDefinitions.googleMapsLocationString(
                latitude: location.latitude,
                longitude: location.longitude
            )
            let url = URL(string: content)
            if let url {
                UIApplication.shared.open(url)
            }
        } else {
            if let url = URLDefinitions.googleMapsAppStoreURL {
                UIApplication.shared.open(url)
            }
        }
    }

    private func handleAppleMaps(location: Pin) {
        location.item.openInMaps()
    }

    private func handleYandexMap(location: Pin) {
        guard let deeplink = URLDefinitions.yandexMapsDeeplinkURL else { return }
        if UIApplication.shared.canOpenURL(deeplink) {
            let content = URLDefinitions.yandexMapsLocationString(
                latitude: location.latitude,
                longitude: location.longitude
            )
            let url = URL(string: content)
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
