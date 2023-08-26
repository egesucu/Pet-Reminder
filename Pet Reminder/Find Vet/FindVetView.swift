//
//  FindVetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct FindVetView: View {

    var vetViewModel = VetViewModel()
    @State private var mapItems: [Pin] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 39.925533,
            longitude: 32.866287
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05,
            longitudeDelta: 0.05
        )
    )
    @State private var userAccess: CLAuthorizationStatus = .notDetermined
    @State private var showAlert = false
    @State private var showSheet = false

    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen

    var body: some View {
        NavigationStack {
            switch userAccess {
            case .authorizedAlways, .authorizedWhenInUse:
                VStack(spacing: 0) {
                    MapWithSearchBarView(mapItems: $mapItems, region: $region, vetViewModel: vetViewModel) {
                        reloadMapView()
                    }
                    .frame(height: UIScreen.main.bounds.height / 2)
                    bottomMapItemsView
                }
            default:
                EmptyPageView(emptyPageReference: .map)
                    .onTapGesture {
                        showAlert.toggle()
                    }
                    .padding(.all)
                    .navigationTitle(Text("find_vet_title"))
            }
        }
        .onAppear(perform: {
            askUserLocation()
            userAccess = vetViewModel.locationManager.authorizationStatus
            reloadMapView()
        })
        .alert(isPresented: $showAlert,
               content: {

            Alert(
                title: Text(
                    "location_alert_title"
                ),
                message: Text(
                    "location_alert_context"
                ),
                primaryButton: Alert.Button.default(Text(
                    "location_alert_change"
                ),
                                                    action: {
                                                        self.changeLocationSettings(
                                                        )
                                                    }),
                secondaryButton: Alert.Button.cancel(
                )
            )

        })
    }

    private var bottomMapItemsView: some View {
        VStack {
#if !targetEnvironment(simulator)
            List {
                ForEach(mapItems) { item in
                    MapItemView(item: item) { mapItem in
                        setRegion(item: mapItem)
                    }
                }
            }
            .listItemTint(.clear)
            .listRowInsets(.none)
            .listStyle(.inset)
#endif
        }
    }
}

extension FindVetView {

    func setRegion(item: MKMapItem) {
        region = MKCoordinateRegion(
            center: item.placemark.coordinate,
            latitudinalMeters: 0.01,
            longitudinalMeters: 0.01
        )
    }
    func changeLocationSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    func reloadMapView() {
        switch userAccess {
        case .authorizedAlways, .authorizedWhenInUse:
            self.region = vetViewModel.region
            vetViewModel.locationManager.startUpdatingLocation()
            setupPins()
            showSheet = true
        default: break
        }

    }

    func setupPins() {
        self.mapItems.removeAll()
        DispatchQueue.main.async {
            self.vetViewModel.searchPins(searchText: vetViewModel.searchText) { result in
                switch result {
                case .success(let pins):
                    self.mapItems = pins
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
                }
            }
        }

    }

    func askUserLocation() {
        vetViewModel.askLocationPermission()
    }
}

#Preview {
    FindVetView()
}
