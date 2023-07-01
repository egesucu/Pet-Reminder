//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) var context
    @Query var pets: [Pet]
    var storeManager: StoreManager
    @AppStorage(Strings.petSaved) var petSaved: Bool = false

    let feedChecker = DailyFeedChecker.shared

    var body: some View {
        petView()
            .onAppear(perform: resetFeedTimes)
            .onChange(of: pets.count, { _, newValue in
                toggleSavedPet(count: newValue)
            })
    }

    @ViewBuilder
    func petView() -> some View {
        if petSaved {
            HomeManagerView(storeManager: storeManager)
        } else {
            HelloView(storeManager: storeManager)
        }
    }

    private func toggleSavedPet(count: Int) {
        petSaved = checkPetCount(count: count)
    }

    private func checkPetCount(count: Int) -> Bool {
        count > 0 ? true : false
    }

    private func resetFeedTimes() {
        petSaved = checkPetCount(count: pets.count)
        if petSaved { feedChecker.resetLogic(pets: pets) }
    }
}
