//
//  PetNotificationSelection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PetNotificationSelection: View {

    @Binding var model: AddPet.Model

    var body: some View {
        notificationType
    }

    @ViewBuilder var notificationType: some View {
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
        VStack(spacing: .spacing8) {
            Label {
                Text(.feedSelectionMorning)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
            }
            DatePicker(
                selection: $model.morningFeed,
                in: ...model.eveningFeed.addingTimeInterval(60),
                displayedComponents: .hourAndMinute
            ) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.label)
        }
        .animation(.easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)

    }

    var eveningView: some View {
        VStack(spacing: .spacing8) {
            Label {
                Text(.feedSelectionEvening)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.blue)
            }
            DatePicker(
                selection: $model.eveningFeed,
                in: model.morningFeed.addingTimeInterval(60)...,
                displayedComponents: .hourAndMinute
            ) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.label)
        }
        .animation(.easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)
    }

    var bothView: some View {
        HStack(spacing: .spacing40) {
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

    PetNotificationSelection(model: $model)
        .padding(.horizontal)
}
#endif
