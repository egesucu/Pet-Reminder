//
//  ESMapView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 11.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import MapKit

struct ESMapView: UIViewRepresentable{
    
    @EnvironmentObject var model: VetViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        
        let view = model.mapView
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        return view
       
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            } else {
                let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PIN_VIEW")
                pinAnnotation.tintColor = .systemGreen
                pinAnnotation.animatesDrop = true
                pinAnnotation.canShowCallout = true
                
                let button = UIButton(type: .detailDisclosure)
                pinAnnotation.rightCalloutAccessoryView = button
                
                return pinAnnotation
            }
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else {
                return
            }
            openMapToGetDirections(annotation: annotation)
           
              
            
        }
        
        func openMapToGetDirections(annotation: MKAnnotation){
            let placemark = MKPlacemark(coordinate: annotation.coordinate)
            let mapItem  = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title ?? "Target"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
           
            
        }
        
    }
}


