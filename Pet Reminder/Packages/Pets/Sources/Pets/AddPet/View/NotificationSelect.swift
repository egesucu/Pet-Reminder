//
//  NotificationSelect.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 30.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI

struct NotificationSelect: View {

    @Binding var model: AddPet.Model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing20) {
            Text(SharedStrings.feedTimeTitle)
                .font(.headline)
                .foregroundStyle(Color.label)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.8), value: model.feedSelection)

            feedingPicker.adaptivePickerStyle()

            notificationType
        }
    }
}

private extension NotificationSelect {
    var feedingPicker: some View {
        Picker(
            selection: $model.feedSelection,
            label: Text(SharedStrings.feedTimeTitle)
        ) {
            ForEach(FeedSelection.allCases, id: \.description) {
                Text($0.localized)
                    .tag($0)
            }
        }
    }

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
                Text(SharedStrings.feedSelectionMorning)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
            }
        }
        .tint(Color.label)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)
    }

    var eveningView: some View {
        DatePicker(
            selection: $model.eveningFeed,
            in: model.morningFeed.addingTimeInterval(60)...,
            displayedComponents: .hourAndMinute
        ) {
            Label {
                Text(SharedStrings.feedSelectionEvening)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.blue)
            }
        }
        .tint(Color.label)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.8), value: model.feedSelection)
        .transition(.identity)
    }

    var bothView: some View {
        VStack(spacing: .spacing40) {
            morningView
            eveningView
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.8), value: model.feedSelection)
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
