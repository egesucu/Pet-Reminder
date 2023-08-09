//
//  MapWithSearchBarView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit

struct MapWithSearchBarView: View {

    @Binding var mapItems: [Pin]
    @Binding var region: MKCoordinateRegion
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen
    @State private var selectedItem: MKMapItem?
    @State var vetViewModel: VetViewModel
    @State private var showAlert = false

    var onReload: () -> Void

    var body: some View {
#if !targetEnvironment(simulator)
            ZStack(alignment: .top) {
                Map(bounds: MapCameraBounds(centerCoordinateBounds: region), interactionModes: .all) {
                    withAnimation {
                        ForEach(mapItems) { pin in
                            Annotation(pin.item.name ?? "", coordinate: pin.item.placemark.coordinate) {
                                Image(systemName: SFSymbols.pawprintCircleFill)
                                    .font(.title)
                                    .padding(2)
                                    .onTapGesture {
                                        selectedItem = pin.item
                                        showAlert.toggle()
                                    }
                            }
                        }
                    }
                }
                TextField("location_search_title", text: $vetViewModel.searchText, onCommit: {
                    onReload()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .shadow(radius: 10)
                .padding()
                .alert("find_vet_open", isPresented: $showAlert) {
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
                        Text("cancel")
                    }
                }

            }
#else
            Text(Strings.simulationError)
#endif
    }
}

#Preview {
    MapWithSearchBarView(mapItems: .constant([]), region: .constant(.init()), vetViewModel: .init(), onReload: { })
}
