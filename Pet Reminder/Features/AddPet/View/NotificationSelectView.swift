//
//  NotificationSelectView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct NotificationSelectView: View {
    
    @Binding var addPet: AddPet

    var body: some View {
        VStack(spacing: 20) {
            Text(.feedTimeTitle)
                .font(.title3)
                .bold()
                .foregroundStyle(Color.label)
                .animation(.easeOut(duration: 0.8), value: addPet.feedSelection)

            Picker(
                selection: $addPet.feedSelection,
                label: Text(.feedTimeTitle)
            ) {
                ForEach(FeedSelection.allCases, id: \.description) {
                    Text($0.localized)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.green)
            .animation(.easeOut(duration: 0.8), value: addPet.feedSelection)
            .padding(.horizontal, 8)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var addPet: AddPet = .init()
    NotificationSelectView(addPet: $addPet)
}
#endif
