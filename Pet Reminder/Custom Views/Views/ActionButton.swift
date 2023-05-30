//
//  ActionButton.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    var action: () -> ()
    var content: LocalizedStringKey
    var systemImage: String
    var isEnabled: Bool
    var tint: Color?
     
    var body: some View {
        Button(action: action) {
            Label(content, systemImage: systemImage)
        }
        .font(.title)
        .tint(tint)
        .buttonStyle(.borderedProminent)
        
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(action: {
            
        }, content: .save, systemImage: SFSymbols.pawprintCircleFill, isEnabled: true, tint: .green)
    }
}
