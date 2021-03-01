//
//  VetViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 24.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class VetViewModel : ObservableObject{
    
    @Published var vets : [Vet] = [Vet]()
    
    
    init() {
        loadVets()
    }
 
    private func loadVets(){
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Veteriner"
        
        let search = MKLocalSearch(request: request)
        
        self.vets.removeAll()
        
        search.start { response, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let result = response {
                    for place in result.mapItems {
                        
                        var foundVet = Vet()
                        foundVet.id = place.name
                        foundVet.name = place.name
                        foundVet.phoneNumber = place.phoneNumber
                        foundVet.coordinate = place.placemark.coordinate
                        
                        self.vets.append(foundVet)
                    }
                }
            }
        }
    }
}

// MARK: User Location Definition

class LocationDelegate : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var userLocation = CLLocation()
    
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
        
        if let location = locations.first {
            self.userLocation = location
        }
        print("New Location")
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    
    
}


struct Vet : Identifiable {
    
    var id                      : String?
    var name                    : String?
    var phoneNumber             : String?
    var coordinate              : CLLocationCoordinate2D?
    
    
    init(){
        id = nil
        name = nil
        phoneNumber = nil
        coordinate = nil
    }
}
