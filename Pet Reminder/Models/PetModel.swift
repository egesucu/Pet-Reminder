//
//  PetModel.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 6.06.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import Foundation


class PetModel: ObservableObject {
    
    @Published var name : String = ""
    @Published var birthday : Date = Date()
    @Published var imageData : Data = Data()
    
    
}
