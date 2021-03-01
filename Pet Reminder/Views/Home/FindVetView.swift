//
//  FindVetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import MapKit

struct FindVetView: View {
    
    @ObservedObject var vets = VetViewModel()
    
    @State private var manager = CLLocationManager()
    @StateObject var managerDelegate = LocationDelegate()
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var defaultLocation = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 41.1090480252826,
            longitude: 28.979255511303712
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 5,
            longitudeDelta: 5
        )
    )

    var body: some View {
        Map(coordinateRegion: $defaultLocation, interactionModes: .all, showsUserLocation : true, userTrackingMode : $userTrackingMode)
            .onAppear(){
                manager.delegate = managerDelegate
                
                if manager.authorizationStatus == .authorizedWhenInUse{
                    manager.requestLocation()
                    let userLocation = managerDelegate.userLocation
                    
                    defaultLocation = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
                }
            }
        
    }
}

struct FindVetView_Previews: PreviewProvider {
    static var previews: some View {
        FindVetView()
    }
}



