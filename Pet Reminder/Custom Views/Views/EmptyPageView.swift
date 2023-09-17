//
//  EmptyPageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct EmptyPageView: View {

    @AppStorage(Strings.tintColor) var tintColor = Color.accent
    var onAddPet: (() -> Void)?
    var emptyPageReference: EmptyPageReference = .none

    var body: some View {
        switch emptyPageReference {
        case .petList:
            VStack {
                Text("pet_no_pet")
                if onAddPet != nil {
                    Button("pet_add_pet", action: onAddPet ?? {})
                        .buttonStyle(.bordered)
                        .tint(tintColor)
                }
            }
        case .settings:
            Text("pet_no_pet")
        case .none:
            EmptyView()
        case .events:
            VStack {
                Text("event_not_allowed")
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("open_settings")
                }
                .buttonStyle(.bordered)
                .tint(tintColor)
            }
        case .map:
            Text("location_alert_context")
        }
    }
}

#Preview {
    EmptyPageView(emptyPageReference: .petList)
}

enum EmptyPageReference {
    case petList, settings, none, events, map
}
