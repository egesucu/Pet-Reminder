//
//  VaccineExtensions.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import Foundation

extension Vaccine {

    var preview: Vaccine {
        return previews.first ?? .init()
    }

    var previews: [Vaccine] {
        var vaccines: [Vaccine] = []
        Strings.demoVaccines.forEach { vaccineName in
            let vaccine = Vaccine(
                date: .randomDate(),
                name: vaccineName
            )
            vaccines.append(vaccine)
        }
        return vaccines
    }
}
