//
//  MorningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

public struct MorningCheckboxView: View {

    @Binding var morningOn: Bool
    
    public init(
        morningOn: Binding<Bool>
    ) {
        self._morningOn = morningOn
    }

    public var body: some View {
        VStack {
            Label {
                Text("feed_selection_morning")
                    .foregroundStyle(Color.label)
                    .font(.title2.bold())
            } icon: {
                Image(systemSymbol: SFSymbol.sunMaxCircleFill)
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: morningOn)
                    .foregroundStyle(.yellow)
                    .font(.largeTitle.bold())
            }
            .font(.title.bold())
            .padding(.bottom)
            CheckBoxView(isChecked: $morningOn)
        }
        .clipShape(.rect(cornerRadius: 20))
        .frame(width: 150, height: 150)
    }
}

#Preview {
    MorningCheckboxView(morningOn: .constant(true))
}
