//
//  VetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 24.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import MapKit
import CoreLocation
import SwiftUI

class VetViewModel : NSObject, ObservableObject{
    
    @Published var vetAnnotations : [MapMarker] = [MapMarker]()
    @Published var userLocation : CLLocation = CLLocation()
    
    private let locationManager = CLLocationManager()
    
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
 
    private func searchVets(){
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Veteriner"
        
        let search = MKLocalSearch(request: request)
        
        self.vetAnnotations.removeAll()
        
        search.start { response, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let result = response {
                    for place in result.mapItems {
                        
                        let foundVet = MapMarker(coordinate: place.placemark.coordinate)
                        
                        self.vetAnnotations.append(foundVet)
                    }
                }
            }
        }
    }
    
    
    func getUserLocation(){
        
    }
}

extension VetViewModel : CLLocationManagerDelegate {
    
    
   
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        
        if manager.authorizationStatus == .authorizedWhenInUse{
            
            //manager.startUpdatingLocation()
            
            print("User authorized for its location")
            
            
            if manager.accuracyAuthorization != .fullAccuracy {
                print("Your location is not precise, wrong placement could occur.")
            }
            
            
            
        } else {
            print("User did not allow any permission.")
            
            manager.requestWhenInUseAuthorization()
        }
        
        
        
    }
    
//     Get the latest location and update the user location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        self.userLocation = location
        
        
    }

}
