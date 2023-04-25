//
//  FindVetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct FindVetView: View {
    
    @StateObject var vetViewModel = VetViewModel()
    @State private var mapItems : [Pin] = []
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.925533, longitude: 32.866287), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var userAccess : CLAuthorizationStatus = .notDetermined
    @State private var showAlert = false
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View {
        NavigationView{
            locationView()
        }
        .onAppear(perform: loadView)
        .alert(isPresented: $showAlert, content: {
            
            Alert(title: Text("location_alert_title"), message: Text("location_alert_context"), primaryButton: Alert.Button.default(Text("location_alert_change"), action: {
                self.changeLocationSettings()
            }), secondaryButton: Alert.Button.cancel())
            
        })
    }
    
    func loadView() {
        DispatchQueue.main.async {
            askUserLocation()
            userAccess = vetViewModel.locationManager.authorizationStatus
            reloadMapView()
        }
        
    }
    
    @ViewBuilder
    func locationView() -> some View {
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
}

extension FindVetView {
    func changeLocationSettings(){
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func reloadMapView(){
        self.region = vetViewModel.region
        vetViewModel.locationManager.startUpdatingLocation()
        setupPins()
        
    }
    
    func setupPins(){
        self.mapItems.removeAll()
        DispatchQueue.main.async {
            self.vetViewModel.searchPins(searchText: vetViewModel.searchText) { result in
                switch result{
                case .success(let pins):
                    self.mapItems = pins
                case .failure(let error):
                    print("Error: ",error.localizedDescription)
                }
            }
        }
        
    }
    
    func askUserLocation(){
        vetViewModel.askLocationPermission()
    }
}

struct FindVetView_Previews: PreviewProvider {
    static var previews: some View {
        FindVetView()
    }
}
