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
#if !targetEnvironment(simulator)
            VStack {
                if viewModel.permissionDenied {
                    EmptyPageView(emptyPageReference: .map)
                        .onTapGesture {
                            viewModel.showAlert.toggle()
                        }
                        .padding(.all)
                        .navigationTitle(Text("find_vet_title"))
                } else {
                    VStack(spacing: 0) {
                        MapWithSearchBarView(viewModel: $viewModel)
                        .frame(height: UIScreen.main.bounds.height / 2)
                        bottomMapItemsView
                    }
                }
            }
            .task(viewModel.getUserLocation)
            .alert("location_alert_title", isPresented: $viewModel.showAlert, actions: alertActions, message: {
                Text("location_alert_context")
            })
#else
            Text("find_vet_simulation_error")
#endif

        }

    }

#if !targetEnvironment(simulator)

    @ViewBuilder
    private func alertActions() -> some View {
        Button(action: {
            Task {
               await viewModel.openAppSettings()
            }
        }, label: { Text("location_alert_change") })
        Button(action: {}, label: { Text("cancel") })
    }

    private var bottomMapItemsView: some View {
        VStack {
            List {
                ForEach(viewModel.searchedLocations) { location in
                    MapItemView(item: location) { item in
                        Task(priority: .userInitiated) {
                            await viewModel.setRegion(item: item)
                        }
                    }
                }
            }
            .listItemTint(.clear)
            .listRowInsets(.none)
            .listStyle(.inset)
        }
    }
#endif
}

#Preview {
    FindVetView()
}
