//
//  MapItem.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
import SwiftUI
import MapKit
import Shared
import SharedUI

struct MapItem: View {

    @State private var presentApps = false

    let location: Pin
    var isSelected = false
    var showsCardStyle = false

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            HStack(alignment: .firstTextBaseline) {
                Text(location.name)
                    .font(.headline)
                    .accessibilityAddTraits(isSelected ? [.isHeader, .isSelected] : .isHeader)

                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                        .accessibilityHidden(true)
                }
            }

            Button(action: openMapDetail) {
                Label {
                    if let fullAddress = location.fullAdress {
                        Text(fullAddress)
                            .font(showsCardStyle ? .subheadline : .body)
                            .foregroundStyle(.primary)
                    } else {
                        Text(SharedStrings.findVetOpen)
                    }
                } icon: {
                    Image(systemName: "location")
                }
                .multilineTextAlignment(.leading)
                .frame(minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)

            if let phoneNumber = location.phoneNumber {
                Button {
                    callThePlace(with: phoneNumber)
                } label: {
                    Label(phoneNumber, systemImage: "phone")
                        .font(showsCardStyle ? .subheadline : .body)
                        .frame(minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
        }
        .tint(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, .spacing8)
        .alert(SharedStrings.findVetOpen, isPresented: $presentApps) {
            ForEach(MapApplication.allCases, id: \.self) { app in
                Button(app.name) {
                    openURLWithMap(
                        location: location,
                        application: app
                    )
                }
            }
            Button(role: .cancel, action: {})
                .buttonStyle(.glassProminent)
        }
    }
}

// MARK: Helpers
private extension MapItem {

    func openMapDetail() {
        presentApps.toggle()
    }

    func callThePlace(with phoneNumber: String) {
        if let url = URL(string: "tel:\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }

    func openURLWithMap(location: Pin, application: MapApplication) {
        switch application {
        case .apple:
            handleAppleMaps(location: location)
        case .google, .yandex:
            handleThirdPartyMap(location: location, application: application)
        }
    }

    func handleAppleMaps(location: Pin) {
        location.item.openInMaps()
    }

    func handleThirdPartyMap(location: Pin, application: MapApplication) {
        guard let deeplinkURL = application.deeplinkURL else { return }

        UIApplication.shared.open(deeplinkURL) { success in
            let urlToOpen = success
                ? application.destinationURL(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                : application.appStoreURL

            if let urlToOpen {
                UIApplication.shared.open(urlToOpen)
            }
        }
    }
}

#if DEBUG

let coordinate = CLLocation(
    latitude: 41.00858,
    longitude: 28.98017
)

let address = MKAddress(
    fullAddress: """
    Alemdar Mahallesi, Yerebatan Caddesi No:1
    Fatih, Istanbul 34110
    Turkey
    """,
    shortAddress: "Yerebatan Caddesi No:1, Fatih"
)

#Preview {

    let item = MKMapItem(location: coordinate, address: address)
    item.name = "Basilica Cistern"
    item.phoneNumber = "+90 212 512 15 70"

    return List {
        MapItem(location: Pin(item: item), isSelected: true)
    }
}
#endif
