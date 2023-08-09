//
//  EmptyPageView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct EmptyPageView: View {
    
    var onAddPet: (() -> Void)?
    var onRefreshEvents: (() -> Void)?
    var emptyPageReference: EmptyPageReference = .none
    
    var body: some View {
        switch emptyPageReference {
        case .petList:
            VStack {
                Text("pet_no_pet")
                Button("pet_add_pet", action: onAddPet ?? {})
                    .buttonStyle(.bordered)
                    .tint(.green)
            }
        case .settings:
            Text("pet_no_pet")
        case .none:
            EmptyView()
        case .events:
            VStack {
                Text("event_no_title")
                Button("refresh", action: onRefreshEvents ?? {})
                    .buttonStyle(.bordered)
                    .tint(.green)
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
