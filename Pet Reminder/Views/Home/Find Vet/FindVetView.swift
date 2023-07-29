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

    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    var body: some View {
        NavigationView {
            switch userAccess {
            case .notDetermined, .restricted, .denied:
                Text("location_alert_context")
                    .onTapGesture {
                        showAlert.toggle()
                    }
                    .padding(.all)
                    .multilineTextAlignment(.center)
                    .navigationTitle(Text("find_vet_title"))
            case .authorizedAlways, .authorizedWhenInUse:
                MapWithSearchBarView(mapItems: $mapItems, region: $region, vetViewModel: vetViewModel) {
                    reloadMapView()
                }

            @unknown default:
                VStack {
                    Text("location_alert_context")
                        .onTapGesture {
                            showAlert.toggle()
                        }.padding(.all).multilineTextAlignment(.center)
                }.navigationTitle(Text("find_vet_title"))
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
        .sheet(isPresented: $showSheet,
               content: {
            VStack {
                List {
                    ForEach(mapItems) { item in
                        VStack {
                            Text(item.item.name ?? "")
                                .bold()
                                .font(.title3)
                                .padding(.bottom, 10)
                            HStack {
                                VStack(alignment: .leading) {
                                    if let phoneNumber = item.item.phoneNumber {
                                        HStack {
                                            Image(systemName: "phone.fill")
                                                .foregroundStyle(tintColor)
                                            Text(phoneNumber)
                                                .foregroundStyle(tintColor)
                                                .onTapGesture {
                                                    let url = URL(
                                                        string: "tel:\(phoneNumber)"
                                                    ) ?? URL(
                                                        string: "https://www.google.com"
                                                    )!
                                                    UIApplication.shared.open(url)
                                                }
                                            Spacer()
                                        }
                                        .tint(tintColor)
                                    }
                                    if let subThoroughfare = item.item.placemark.subThoroughfare,
                                       let thoroughfare = item.item.placemark.thoroughfare,
                                       let locality = item.item.placemark.locality,
                                       let postalCode = item.item.placemark.postalCode {
                                        HStack {
                                            Image(systemName: "building.fill")
                                                .foregroundStyle(tintColor)
                                            Text("\(thoroughfare), \(subThoroughfare) \n\(postalCode), \(locality)")
                                            Spacer()
                                        }

                                    }
                                }
                                Spacer()
                                Button(action: {
                                    setRegion(item: item.item)
                                }, label: {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                })
                                .padding(.trailing, 10)
                            }

                        }

                    }
                }
                .listItemTint(.clear)
                .listRowInsets(.none)
                .listStyle(.inset)
            }
            .presentationDetents([.medium, .large, .height(120)])
            .presentationCornerRadius(10)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        })
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
