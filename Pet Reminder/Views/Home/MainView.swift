//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct MainView: View {
    @State private var loading = true
    @State private var viewModel = MainViewModel()
    @Environment(\.modelContext) var modelContext

    // Capture NOTIFICATION changes
    var didRemoteChange = NotificationCenter
        .default
        .publisher(for: .NSPersistentStoreRemoteChange)
        .receive(on: RunLoop.main)

    var body: some View {
        petView()
            .onReceive(self.didRemoteChange) { _ in
                viewModel.getPets(context: modelContext)
                checkPets()
            }
            .onChange(of: $viewModel.pets.count) { _, _ in
                checkPets()
            }
    }

    func checkPets() {
        if $viewModel.pets.count > 0 {
            self.loading = false
        } else {
            print(viewModel.pets.count)
        }
    }

    @ViewBuilder
    func petView() -> some View {
        if loading {
            VStack {
                Text("Data found in CloudKit, fetching data")
                    .bold()
                    .foregroundStyle(Color(.label))
                ProgressView()
                    .tint(Color(.label))
                    .font(.title)
            }

        } else {
            if $viewModel.pets.count > 0 {
                HomeManagerView()
            } else {
                HelloView()
            }
        }
    }
}
