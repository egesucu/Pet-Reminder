//
//  Chip.swift
//  Pet Reminder
//
//  Created by Sucu, Ege on 09.05.26.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI

public struct Chip: View {
    
    let title: String
    let selected: Bool
    let onTap: () -> Void
    
    public init(
        title: String,
        selected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.selected = selected
        self.onTap = onTap
    }
    
    public var body: some View {
        Text(title)
            .foregroundStyle(
                selected
                ? Color.background
                : Color.label
            )
            .bold(selected)
            .padding(.spacing8)
            .background(
                selected
                ? Color.green
                : Color.green.opacity(0.3)
            )
            .clipShape(.capsule)
            .animation(.snappy, value: selected)
            .onTapGesture(perform: onTap)
            .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selected: Bool = false
    
    Chip(title: "Viski", selected: selected) {
        selected.toggle()
    }
}

#endif
