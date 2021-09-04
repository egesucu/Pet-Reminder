//
//  NextButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 14.05.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI


struct NextButton : ButtonStyle {
    
    var conditionMet: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .foregroundColor(.white)
            .padding()
            .background(conditionMet ? Color.gray.opacity(0.4) : Color.green)
            .cornerRadius(15)
            .shadow(radius: 10)
            .disabled(conditionMet)
    }
    
}
