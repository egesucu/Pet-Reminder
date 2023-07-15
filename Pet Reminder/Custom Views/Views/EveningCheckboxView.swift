//
//  EveningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
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
                Image(systemName: SFSymbols.eveningToggleSelected)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.blue)
                    .font(.largeTitle.bold())
                    .symbolEffect(.bounce, value: eveningOn)
            }
            .padding(.bottom)
            Image(systemName: eveningOn ? SFSymbols.checked : SFSymbols.notChecked)
                .contentTransition(.symbolEffect(.replace))
                .font(.system(size: 50))
                .onTapGesture {
                    eveningOn.toggle()
                }
        }
        .cornerRadius(20)
        .frame(width: 150, height: 150)

    }
}

#Preview {
    EveningCheckboxView(eveningOn: .constant(true))
}
