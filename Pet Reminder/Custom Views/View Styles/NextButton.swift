//
//  NextButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 14.05.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct NextButton: ButtonStyle {

    var conditionMet: Bool
    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .background(conditionMet ? Color.gray.opacity(0.4) : tintColor)
            .clipShape(.rect(cornerRadius: 15))
            .shadow(radius: 10)
            .disabled(conditionMet)
    }

}
