//
//  EveningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

public struct EveningCheckboxView: View {

    @Binding var eveningOn: Bool
    
    public init(
        eveningOn: Binding<Bool>
    ) {
        self._eveningOn = eveningOn
    }

    public var body: some View {
        VStack {
            Label {
                Text("feed_selection_evening")
                    .foregroundStyle(Color.label)
                    .font(.title2.bold())
            } icon: {
                Image(systemSymbol: SFSymbol.moonCircleFill)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
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
        Image(
            systemSymbol: isChecked ? SFSymbol.checkmarkSquare : SFSymbol.square
        )
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
