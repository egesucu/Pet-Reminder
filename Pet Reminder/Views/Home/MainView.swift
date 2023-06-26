//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)])
    var pets: FetchedResults<Pet>
    @StateObject var storeManager: StoreManager
    @AppStorage(Strings.petSaved) var petSaved: Bool = false

    let feedChecker = DailyFeedChecker.shared

    var body: some View {
        petView()
            .onAppear(perform: resetFeedTimes)
            .onChange(of: pets.count, perform: toggleSavedPet(count:))
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
        if petSaved { feedChecker.resetLogic(pets: pets, context: context) }
    }
}
