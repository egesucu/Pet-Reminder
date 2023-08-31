//
//  MapWithSearchBarView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
#if !targetEnvironment(simulator)
import SwiftUI
import MapKit

struct MapWithSearchBarView: View {

    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen
    @Binding var viewModel: VetViewModel

    var body: some View {

            ZStack(alignment: .top) {
                Map(bounds: MapCameraBounds(centerCoordinateBounds: viewModel.region), interactionModes: .all) {
                    withAnimation {
                        ForEach(viewModel.searchedLocations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: SFSymbols.pawprintCircleFill)
                                    .font(.title)
                                    .padding(2)
                                    .onTapGesture {
                                        viewModel.selectedItem = location
                                        viewModel.showAlert.toggle()
                                    }
                            }
                        }
                    }
                }
                TextField("location_search_title", text: $viewModel.searchText, onCommit: {
                    Task {
                        await viewModel.searchPins()
                    }
                })
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 10)
                    .padding()
                    .alert("find_vet_open", isPresented: $viewModel.showAlert) {
                    ForEach(MapApplication.allCases, id: \.self) { app in
                        Button(app.rawValue) {
                            let location = viewModel.selectedItem
                            openURLWithMap(
                                latitude: location.latitude,
                                longitude: location.longitude,
                                application: app
                            )
                        }
                    }
                    Button {
                        viewModel.showAlert.toggle()
                    } label: {
                        Text("cancel")
                    }
                }
            }
    }
}
#endif
