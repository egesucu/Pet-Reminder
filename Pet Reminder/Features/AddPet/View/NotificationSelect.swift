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
        VStack(alignment: .leading, spacing: .spacing20) {
            Text(.feedTimeTitle)
                .font(.headline)
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
            .animation(.easeOut(duration: 0.8), value: model.feedSelection)
            
            notificationType
        }
    }
}

private extension NotificationSelect {
    @ContentBuilder var notificationType: some View {
        switch model.feedSelection {
        case .morning:
            morningView
        case .evening:
            eveningView
        default:
            bothView
        }
    }
    
    var morningView: some View {
        DatePicker(
            selection: $model.morningFeed,
            in: ...model.eveningFeed.addingTimeInterval(60),
            displayedComponents: .hourAndMinute
        ) {
            Label {
                Text(.feedSelectionMorning)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .tint(Color.label)
        .animation(.easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)
    }

    var eveningView: some View {
        DatePicker(
            selection: $model.eveningFeed,
            in: model.morningFeed.addingTimeInterval(60)...,
            displayedComponents: .hourAndMinute
        ) {
            Label {
                Text(.feedSelectionEvening)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.blue)
            }
        }
        .tint(Color.label)
        .animation(.easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)
    }

    var bothView: some View {
        VStack(spacing: .spacing40) {
            morningView
            eveningView
        }
        .animation(.easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var model: AddPet.Model = .init()
    
    NotificationSelect(model: $model)
        .padding(.horizontal)
}
#endif
