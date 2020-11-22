//
//  PetInfo.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 21.11.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import CoreData


class PetInfo : ObservableObject {
    
    @Published var id = UUID()
    @Published var name = ""
    @Published var image = Data()
    @Published var birthday = Date()
    @Published var eveningTime = Date()
    @Published var morningTime = Date()
    @Published var eveningFed = false
    @Published var morningFed = false
    
}
