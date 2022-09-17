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
    @ObservedObject var vetViewModel: VetViewModel
    
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
                                    annotation.item.openInMaps(launchOptions: nil)
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
                .padding()            }
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
