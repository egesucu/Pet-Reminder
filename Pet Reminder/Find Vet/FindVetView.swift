//
//  FindVetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 7.02.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct FindVetView: View {

    @State private var viewModel = VetViewModel()
    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    var body: some View {
        NavigationStack {
            VStack {
#if !targetEnvironment(simulator)
                VStack {
                    if viewModel.permissionDenied {
                        EmptyPageView(emptyPageReference: .map)
                            .padding(.all)
                        
                    } else {
                        Map(selection: $viewModel.selectedLocation) {
                            withAnimation {
                                ForEach(viewModel.searchedLocations) { location in
                                    Marker(location.name, systemImage: SFSymbols.pawprintCircleFill , coordinate: location.coordinate)
                                        .tint(tintColor)
                                        .tag(location)
                                    UserAnnotation()
                                }
                            }
                        }
                        .mapControls {
                            MapPitchToggle()
                            MapUserLocationButton()
                            MapCompass()
                        }
                        .searchable(text: $viewModel.searchText)
                        
                    }
                }
                .task(viewModel.getUserLocation)
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.searchPins()
                    }
                }
                .onChange(of: viewModel.selectedLocation) {
                    viewModel.showItem = viewModel.selectedLocation != nil
                    
                }
#else
                Text("find_vet_simulation_error")
#endif
            }
            .sheet(isPresented: $viewModel.showItem, onDismiss: {
                viewModel.selectedLocation = nil
            }, content: {
                MapItemView(location: viewModel.selectedLocation)
                    .presentationDetents([.height(180)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(25)
                    .padding(.horizontal)
            })
            
            .navigationTitle(Text("find_vet_title"))
            
        }

    }
}

#Preview {
    FindVetView()
}
