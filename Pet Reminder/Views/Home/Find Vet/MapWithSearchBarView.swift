//
//  MapWithSearchBarView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2022.
//  Copyright © 2022 Softhion. All rights reserved.
//

import SwiftUI
import MapKit

struct MapWithSearchBarView: View {
    
    @Binding var mapItems : [Pin]
    @Binding var region : MKCoordinateRegion
    @AppStorage("tint_color") var tintColor = Color(uiColor: .systemGreen)
    @State private var selectedItem : MKMapItem? = nil
    @ObservedObject var vetViewModel: VetViewModel
    @State private var showAlert = false
    
    var onReload : () -> (Void)
    
    var body: some View {
        ZStack(alignment: .center){
#if !targetEnvironment(simulator)
            ZStack(alignment: .top) {
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
                                    selectedItem = annotation.item
                                    showAlert.toggle()
                                    
                                }
                                
                                .animation(.easeInOut, value: 1)
                        }
                    }
                }.edgesIgnoringSafeArea(.top)
                TextField("location_search_title", text: $vetViewModel.searchText, onCommit: {
                    onReload()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .shadow(radius: 10)
                .padding()
                .alert("find_vet_open", isPresented: $showAlert) {
                    Button {
                        if let selectedItem{
                            selectedItem.openInMaps(launchOptions: nil)
                        }
                    } label: {
                        Text("apple_maps")
                    }
                    Button {
                        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!){
                            if let selectedItem{
                                let lat = selectedItem.placemark.coordinate.latitude
                                let long = selectedItem.placemark.coordinate.longitude
                                let url = URL(string: "comgooglemaps://?saddr=&daddr=\(lat),\(long)")
                                if let url{
                                    UIApplication.shared.open(url)
                                }
                            }
                        } else {
                            UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/google-maps/id585027354")!)
                        }
                        
                        
                    } label: {
                        Text("google_maps")
                    }
                    Button {
                        if UIApplication.shared.canOpenURL(URL(string:"yandexnavi://")!){
                            if let selectedItem{
                                let lat = selectedItem.placemark.coordinate.latitude
                                let long = selectedItem.placemark.coordinate.longitude
                                let url = URL(string: "yandexnavi://build_route_on_map?lat_to=" + "\(lat)" + "&lon_to=" + "\(long)")
                                if let url{
                                    UIApplication.shared.open(url)
                                }
                            }
                        } else {
                            UIApplication.shared.open(URL(string: "https://itunes.apple.com/ru/app/yandex.navigator/id474500851")!)
                        }
                        
                        
                    } label: {
                        Text("yandex_navi")
                    }
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text("cancel")
                    }
                }
            }
#else
            Text("Simulation does not support User Location")
#endif
                
        }
    }
}

struct MapWithSearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithSearchBarView(mapItems: .constant([]), region: .constant(.init()), vetViewModel: .init(), onReload: { })
    }
}
