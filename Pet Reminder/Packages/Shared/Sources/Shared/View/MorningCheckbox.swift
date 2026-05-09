//
//  MorningCheckbox.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

public struct MorningCheckbox: View {

    @Binding var morningOn: Bool

    public init(
        morningOn: Binding<Bool>
    ) {
        self._morningOn = morningOn
    }

    public var body: some View {
        VStack(spacing: .spacing8) {
            Label {
                Text(.feedSelectionMorning)
                    .foregroundStyle(Color.label)
                    .lineLimit(nil)
            } icon: {
                Image(systemName: "sun.max.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: morningOn)
                    .foregroundStyle(.yellow)
            }
            .font(.largeTitle.bold())
            .padding(.bottom, .spacing8)
            CheckBoxView(isChecked: $morningOn)
        }
        .clipShape(.rect(cornerRadius: .radius20))
        .frame(idealWidth: .avatar150, idealHeight: .avatar150)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var isOn = false

    MorningCheckbox(morningOn: $isOn)
}
#endif
