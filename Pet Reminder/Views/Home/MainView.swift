//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
        private var pets: FetchedResults<Pet>

    @AppStorage(Strings.petSaved) var petSaved: Bool = false

    var body: some View {
        petView()
            .onChange(of: pets.count, { _, newValue in
                toggleSavedPet(count: newValue)
            })
    }

    @ViewBuilder
    func petView() -> some View {
        if petSaved {
            HomeManagerView()
        } else {
            HelloView()
        }
    }

    private func toggleSavedPet(count: Int) {
        petSaved = checkPetCount(count: count)
    }

    private func checkPetCount(count: Int) -> Bool {
        count > 0 ? true : false
    }
}
