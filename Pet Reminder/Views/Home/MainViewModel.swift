//
//  MainViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Observation
import SwiftData
import SwiftUI

@Observable
class MainViewModel {
    var pets: [Pet] = []

    func getPets(context: ModelContext) {
//        let sort = SortDescriptor(\Pet.name)
        let request = FetchDescriptor<Pet>()

            do {
                pets = try context.fetch(request)
            } catch let error {
                print("Error fetching cars. \(error.localizedDescription)")
            }
        }
}
