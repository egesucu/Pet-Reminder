//
//  FindVetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct FindVetView: View {
    
    @StateObject var vetViewModel = VetViewModel()
    @State private var mapItems : [Pin] = []
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var pinLoaded = false
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    
    var body: some View {
        ZStack(alignment: .center){
            ZStack(alignment: .top) {
                withAnimation {
                    Map(coordinateRegion: $region,interactionModes: .all,showsUserLocation: true, annotationItems: mapItems) { annotation in
                        withAnimation {
                            MapAnnotation(coordinate: annotation.item.placemark.coordinate) {
                                VStack{
                                    Image(systemName: "pawprint.circle.fill")
                                        .font(.largeTitle)
                                        .padding(2)
                                }.background(tintColor)
                                    .cornerRadius(15)
                                    .shadow(radius:8)
                                    .scaleEffect(1)
                                    .onTapGesture {
                                        annotation.item.openInMaps(launchOptions: nil)
                                    }
                                    .animation(.easeInOut, value: 1)
                            }
                        }
                    }.edgesIgnoringSafeArea(.top)
                }
                
                TextField("location_search_title", text: $vetViewModel.searchText, onCommit: {
                    reloadMapView()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .shadow(radius: 10)
                .padding()
            }
            if pinLoaded {
                ProgressView()
                    .progressViewStyle(.circular)
            }
                
        }
        .onAppear(perform: {
            askUserLocation()
            reloadMapView()
            pinLoaded = false
        })
        .alert(isPresented: $vetViewModel.permissionDenied, content: {
            
            Alert(title: Text("location_alert_title"), message: Text("location_alert_context"), primaryButton: Alert.Button.default(Text("location_alert_change"), action: {
                self.changeLocationSettings()
            }), secondaryButton: Alert.Button.cancel())
            
        })
        
    }
}

extension FindVetView {
    func changeLocationSettings(){
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func reloadMapView(){
        pinLoaded = true
        self.region = vetViewModel.region
        vetViewModel.locationManager.startUpdatingLocation()
        setupPins()
        
    }
    
    func setupPins(){
        self.mapItems.removeAll()
        self.vetViewModel.searchPins(searchText: vetViewModel.searchText) { result in
            switch result{
            case .success(let pins):
                self.mapItems = pins
                pinLoaded = false
            case .failure(let error):
                print("Error: ",error.localizedDescription)
                pinLoaded = false
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
