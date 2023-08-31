//
//  VaccineHistoryViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import Foundation
import SwiftUI
import Observation
import CoreData

@Observable
class VaccineHistoryViewModel {

   var vaccineName = ""
   var vaccineDate = Date.now
   var shouldAddVaccine = false

    func cancelVaccine() {
        togglePopup()
        resetTemporaryData()
    }

    func togglePopup() {
        withAnimation {
            shouldAddVaccine.toggle()
        }
    }

    func saveVaccine(pet: Pet?) {
        let vaccine = Vaccine()
        vaccine.name = vaccineName
        vaccine.date = vaccineDate
        pet?.addToVaccines(vaccine)
        PersistenceController.shared.save()

        resetTemporaryData()
        togglePopup()
    }

    func resetTemporaryData() {
        vaccineName = ""
        vaccineDate = .now
    }

    func deleteVaccines(pet: Pet?, at offsets: IndexSet, modelContext: NSManagedObjectContext) {
        if let pet,
           let vaccineSet = pet.vaccines,
           let vaccines = vaccineSet.allObjects as? [Vaccine] {
            for offset in offsets {
                modelContext.delete(vaccines[offset])
            }
        }
    }
}
