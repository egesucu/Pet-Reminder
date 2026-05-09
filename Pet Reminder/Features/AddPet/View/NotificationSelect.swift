//
//  NotificationSelect.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct NotificationSelect: View {
    
    @Binding var model: AddPet.Model
        
    var body: some View {
        VStack(spacing: .spacing20) {
            Text(.feedTimeTitle)
                .font(.title3)
                .bold()
                .foregroundStyle(Color.label)
                .animation(.easeOut(duration: 0.8), value: model.feedSelection)

            Picker(
                selection: $model.feedSelection,
                label: Text(.feedTimeTitle)
            ) {
                ForEach(FeedSelection.allCases, id: \.description) {
                    Text($0.localized)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.green)
            .animation(.easeOut(duration: 0.8), value: model.feedSelection)
            .padding(.horizontal, .spacing8)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var model: AddPet.Model = .init()
    NotificationSelect(model: $model)
}
#endif
