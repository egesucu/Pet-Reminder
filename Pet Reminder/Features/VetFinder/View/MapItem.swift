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

struct MapItem: View {

    @State private var presentApps = false
    
    let location: Pin

    var body: some View {
        VStack(spacing: .spacing16) {
            HStack(spacing: .zero) {
                Spacer()
                
                Text(location.name)
                    .bold()
                    .font(.title3)
                
                Spacer()
            }
            
            if let phoneNumber = location.phoneNumber {
                Text(phoneNumber)
                    .foregroundStyle(.accent)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        callThePlace(with: phoneNumber)
                    }
                    .accessibilityAddTraits(.isLink)
            }
            
            if let fullAdress = location.fullAdress {
                Text(fullAdress)
                    .foregroundStyle(.blue)
                    .multilineTextAlignment(.center)
                    .onTapGesture(perform: openMapDetail)
                    .accessibilityAddTraits(.isButton)
            }
        }
        .padding(.spacing8)
        .alert(.findVetOpen, isPresented: $presentApps) {
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

        let urlToOpen: URL?
        if UIApplication.shared.canOpenURL(deeplinkURL) {
            urlToOpen = application.destinationURL(
                latitude: location.latitude,
                longitude: location.longitude
            )
        } else {
            urlToOpen = application.appStoreURL
        }

        if let urlToOpen {
            UIApplication.shared.open(urlToOpen)
        }
    }
}

#if DEBUG

import Contacts

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
    
    return Color
        .gray
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            MapItem(
                location: Pin(item: item)
            )
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
}
#endif
