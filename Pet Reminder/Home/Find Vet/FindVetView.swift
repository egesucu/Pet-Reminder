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
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ESMapView()
                .environmentObject(vetViewModel)
                .edgesIgnoringSafeArea(.top)
                
            
            TextField("Search", text: $vetViewModel.searchText, onCommit: {
                self.vetViewModel.searchPins()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .shadow(radius: 10)
            .padding()
            
        }.onAppear(perform: {
            locationManager.delegate = vetViewModel
            locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.vetViewModel.searchPins()
            }
            
        })
        .alert(isPresented: $vetViewModel.permissionDenied, content: {
            
            Alert(title: Text("Alert"), message: Text("Location permission denied. In order to work with this page, you need to allow us from app settings"), primaryButton: Alert.Button.default(Text("Change"), action: {
                self.changeLocationSettings()
            }), secondaryButton: Alert.Button.cancel())
            
        })
        .onChange(of: vetViewModel.searchText, perform: { value in
    
            #if !targetEnvironment(simulator)
            let delay = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if value == vetViewModel.searchText{
                    self.vetViewModel.searchPins()
                }
            }
            #endif
        })
        
    }
}

extension FindVetView {
    func changeLocationSettings(){
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

struct FindVetView_Previews: PreviewProvider {
    static var previews: some View {
        FindVetView()
    }
}



