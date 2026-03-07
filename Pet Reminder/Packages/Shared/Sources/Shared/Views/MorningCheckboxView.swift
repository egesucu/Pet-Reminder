//
//  MorningCheckboxView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.12.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

public struct MorningCheckboxView: View {

    @Binding var morningOn: Bool

    public init(
        morningOn: Binding<Bool>
    ) {
        self._morningOn = morningOn
    }

    public var body: some View {
        VStack(spacing: PRSpacing.spacing8) {
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
            .padding(.bottom, PRSpacing.spacing8)
            CheckBoxView(isChecked: $morningOn)
        }
        .clipShape(.rect(cornerRadius: PRRadius.radius20))
        .frame(idealWidth: PRComponentSize.avatar150, idealHeight: PRComponentSize.avatar150)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var isOn = false

    MorningCheckboxView(morningOn: $isOn)
}
#endif
