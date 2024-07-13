//
//  VaccineHistoryViewModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation
import SwiftUI
import Observation
import SwiftData
import OSLog

@MainActor
@Observable
public class VaccineHistoryViewModel {
    
    public var vaccineName = ""
    public var vaccineDate = Date.now
    public var shouldAddVaccine = false
    
    public init(
        vaccineName: String = "",
        vaccineDate: Foundation.Date = Date.now,
        shouldAddVaccine: Bool = false
    ) {
        self.vaccineName = vaccineName
        self.vaccineDate = vaccineDate
        self.shouldAddVaccine = shouldAddVaccine
    }
    
    public func cancelVaccine() {
        togglePopup()
        resetTemporaryData()
    }
    
    public func togglePopup() {
        withAnimation {
            shouldAddVaccine.toggle()
        }
    }
    
    public func saveVaccine(pet: Pet?) {
        guard let pet else { return }
        let vaccine = Vaccine()
        vaccine.name = vaccineName
        vaccine.date = vaccineDate
        pet.vaccines?.append(vaccine)
        
        resetTemporaryData()
        togglePopup()
    }
    
    public func resetTemporaryData() {
        vaccineName = ""
        vaccineDate = .now
    }
    
    public func deleteVaccines(pet: Pet?, at offsets: IndexSet) {
        if let pet,
           let vaccines = pet.vaccines {
            for offset in offsets {
                pet.modelContext?.delete(vaccines[offset])
            }
        }
    }
}
