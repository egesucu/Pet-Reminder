//
//  MainViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.07.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Observation
import CoreData
import SwiftUI

@Observable
class MainViewModel {
    var pets: [Pet] = []
    let persistence = PersistenceController.shared

    init() {
        getPets()
    }

    func getPets() {
            let request = NSFetchRequest<Pet>(entityName: "Pet")
            let sort = NSSortDescriptor(keyPath: \Pet.name, ascending: true)
            request.sortDescriptors = [sort]
            do {
                pets =  try persistence.container.viewContext.fetch(request)
            } catch let error {
                print("Error fetching cars. \(error.localizedDescription)")
            }
        }
}
