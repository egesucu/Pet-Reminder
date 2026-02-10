//
//  EveningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

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
                Text(String(localized: .feedSelectionEvening))
                    .foregroundStyle(Color.label)
                    .lineLimit(nil)
            } icon: {
                Image(systemName: "moon.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce, value: eveningOn)
            }
            .font(.largeTitle.bold())
            .padding(.bottom)
            CheckBoxView(isChecked: $eveningOn)
        }
        .clipShape(.rect(cornerRadius: 20))
        .frame(idealWidth: 150, idealHeight: 150)

    }
}

struct CheckBoxView: View {

    @Binding var isChecked: Bool

    var body: some View {
        Image(
            systemName: isChecked
            ? "checkmark.square"
            : "square"
        )
            .contentTransition(.symbolEffect(.replace))
            .font(.largeTitle)
            .onTapGesture(perform: toggleCheck)
    }

    func toggleCheck() {
        isChecked.toggle()
    }
}

#if DEBUG
#Preview {
    @Previewable @State var isOn = false

    EveningCheckboxView(eveningOn: $isOn)
        .environment(\.locale, .init(identifier: "en"))
}
#endif
