//
//  PetNotificationSelectionView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PetNotificationSelectionView: View {

    @Binding var addPet: AddPet

    var body: some View {
        notificationType
    }

    @ViewBuilder var notificationType: some View {
        switch addPet.feedSelection {
        case .morning:
            morningView
        case .evening:
            eveningView
        default:
            bothView
        }
    }

    var morningView: some View {
        VStack(spacing: PRSpacing.spacing8) {
            Label {
                Text(.feedSelectionMorning)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.yellow)
            }
            DatePicker(
                selection: $addPet.morningFeed,
                in: ...addPet.eveningFeed.addingTimeInterval(60),
                displayedComponents: .hourAndMinute
            ) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.label)
        }
        .animation(.easeOut(duration: 0.8), value: addPet.feedSelection)
        .transition(.identity)

    }

    var eveningView: some View {
        VStack(spacing: PRSpacing.spacing8) {
            Label {
                Text(.feedSelectionEvening)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.blue)
            }
            DatePicker(
                selection: $addPet.eveningFeed,
                in: addPet.morningFeed.addingTimeInterval(60)...,
                displayedComponents: .hourAndMinute
            ) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.label)
        }
        .animation(.easeOut(duration: 0.8), value: addPet.feedSelection)
        .transition(.identity)
    }

    var bothView: some View {
        HStack(spacing: PRSpacing.spacing40) {
            morningView
            eveningView
        }
        .animation(.easeOut(duration: 0.8), value: addPet.feedSelection)
        .transition(.identity)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var addPet: AddPet = .init()

    PetNotificationSelectionView(addPet: $addPet)
        .padding(.horizontal)
}
#endif
