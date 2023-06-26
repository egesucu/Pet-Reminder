//
//  EveningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct EveningCheckboxView: View {

    @Binding var eveningOn: Bool

    var body: some View {
        VStack {
            Label {
                Text("feed_selection_evening")
                    .foregroundColor(Color(uiColor: .label))
                    .font(.title2.bold())
            } icon: {
                Image(systemName: eveningOn ? SFSymbols.eveningToggleSelected : SFSymbols.eveningToggle)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.blue)
                    .font(.largeTitle.bold())
                    .animation(.easeInOut, value: eveningOn)
            }
            .padding(.bottom)
            withAnimation {
                Image(systemName: eveningOn ? SFSymbols.checked : SFSymbols.notChecked)
                    .font(.system(size: 50))
                    .animation(.easeInOut, value: eveningOn)
            }
        }
        .cornerRadius(20)
        .frame(width: 150, height: 150)

    }
}

struct EveningView_Previews: PreviewProvider {
    static var previews: some View {
        EveningCheckboxView(eveningOn: .constant(true))
    }
}
