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
                    .foregroundStyle(ESColor.label)
                    .font(.title2.bold())
            } icon: {
                Image(systemName: SFSymbols.eveningToggleSelected)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.blue)
                    .font(.largeTitle.bold())
                    .symbolEffect(.bounce, value: eveningOn)
            }
            .padding(.bottom)
            CheckBoxView(isChecked: $eveningOn)
        }
        .clipShape(.rect(cornerRadius: 20))
        .frame(width: 150, height: 150)

    }
}

struct CheckBoxView: View {

    @Binding var isChecked: Bool

    var body: some View {
        Image(systemName: isChecked ? SFSymbols.checked : SFSymbols.notChecked)
            .contentTransition(.symbolEffect(.replace))
            .font(.system(size: 50))
            .onTapGesture(perform: toggleCheck)
    }

    func toggleCheck() {
        isChecked.toggle()
    }
}

#Preview {
    EveningCheckboxView(eveningOn: .constant(true))
}
