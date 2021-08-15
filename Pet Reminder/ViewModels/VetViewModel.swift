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
    
    @Published var userLocation = CLLocation()
    
    @Published var mapView = MKMapView()
    @Published var region : MKCoordinateRegion!
    @Published var permissionDenied = false
    @Published var searchText = "Vet"
    @Published var places = [VetPin]()
    
    func searchPins(){
        
        places.removeAll()
        
        let searchRequest = MKLocalSearch.Request()
        
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { response, error in
            if let error = error {
                print(error)
            } else if let response = response{
                self.places = response.mapItems.compactMap({ (item) -> VetPin? in
                    return VetPin(place: item.placemark)
                })
                self.showPlaces()
            }
        }
    }
    
    func showPlaces(){
        mapView.removeAnnotations(mapView.annotations)
        
        self.places.forEach { place in
            if let location = place.place.location{
                
                let coordinate = location.coordinate
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinate
                pointAnnotation.title = place.place.name ?? "No Name"
                
                self.mapView.addAnnotation(pointAnnotation)
                
            } else {
                return
            }
            
        }
        
        guard !self.places.isEmpty else {
            return
        }
        if let location = places[0].place.location{
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapView.setRegion(coordinateRegion, animated: true)
            self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        }
       
    }
    
    
    
}

extension VetViewModel : CLLocationManagerDelegate{
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied:
            permissionDenied.toggle()
            break
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error.localizedDescription)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
        
        
    }
    
}
