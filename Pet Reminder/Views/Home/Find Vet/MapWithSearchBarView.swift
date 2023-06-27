//
//  MapWithSearchBarView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2022.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit

struct MapWithSearchBarView: View {

    @Binding var mapItems: [Pin]
    @Binding var region: MKCoordinateRegion
//    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)
    @State private var selectedItem: MKMapItem?
    @ObservedObject var vetViewModel: VetViewModel
    @State private var showAlert = false

    var onReload: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
#if !targetEnvironment(simulator)
            ZStack(alignment: .top) {
                Map(
                    coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: mapItems
                ) { annotation in
                    withAnimation {
                        MapAnnotation(coordinate: annotation.item.placemark.coordinate) {
                            VStack {
                                Image(systemName: SFSymbols.pawprintCircleFill)
                                    .font(.largeTitle)
                                    .padding(2)
                            }.background(tintColor)
                                .cornerRadius(15)
                                .shadow(radius: 8)
                                .scaleEffect(1)
                                .onTapGesture {
                                    selectedItem = annotation.item
                                    showAlert.toggle()

                                }

                                .animation(.easeInOut, value: 1)
                        }
                    }
                }.edgesIgnoringSafeArea(.top)
                TextField(Strings.locationSearchTitle, text: $vetViewModel.searchText, onCommit: {
                    onReload()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .shadow(radius: 10)
                .padding()
                .alert(Strings.findVetOpen, isPresented: $showAlert) {

                    ForEach(MapApplication.allCases, id: \.self) { item in
                        Button(item.rawValue) {
                            if let selectedItem {
                                let lat = selectedItem.placemark.coordinate.latitude
                                let long = selectedItem.placemark.coordinate.longitude
                                openURLWithMap(latitude: lat, longitude: long, application: item)
                            }
                        }
                    }
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text(Strings.cancel)
                    }
                }
            }
#else
            Text(Strings.simulationError)
#endif

        }
    }
}

struct MapWithSearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        MapWithSearchBarView(mapItems: .constant([]), region: .constant(.init()), vetViewModel: .init(), onReload: { })
    }
}
