//
//  PetNotificationSelectionView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SFSafeSymbols

struct PetNotificationSelectionView: View {

    @Binding var feedSelection: FeedSelection
    @Binding var morningFeed: Date
    @Binding var eveningFeed: Date

    var body: some View {
        notificationType()
    }

    @ViewBuilder
    func notificationType() -> some View {
        switch feedSelection {
        case .morning:
            morningView
        case .evening:
            eveningView
        default:
            bothView
        }
    }

    var morningView: some View {
        VStack(spacing: 8) {
            Label {
                Text(.feedSelectionMorning)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemSymbol: .sunMaxFill)
                    .foregroundStyle(.yellow)
            }
            DatePicker(
                selection: $morningFeed,
                in: ...eveningFeed.addingTimeInterval(60),
                displayedComponents: .hourAndMinute
            ) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.label)
        }
        .animation(.easeOut(duration: 0.8), value: feedSelection)
        .transition(.identity)

    }

    var eveningView: some View {
        VStack(spacing: 8) {
            Label {
                Text(.feedSelectionEvening)
                    .foregroundStyle(Color.label)
            } icon: {
                Image(systemSymbol: .moonFill)
                    .foregroundStyle(.blue)
            }
            DatePicker(
                selection: $eveningFeed,
                in: morningFeed.addingTimeInterval(60)...,
                displayedComponents: .hourAndMinute
            ) {
                EmptyView()
            }
            .labelsHidden()
            .tint(Color.label)
        }
        .animation(.easeOut(duration: 0.8), value: feedSelection)
        .transition(.identity)
    }

    var bothView: some View {
        HStack(spacing: 40) {
            morningView
            eveningView
        }
        .animation(.easeOut(duration: 0.8), value: feedSelection)
        .transition(.identity)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var feedSelection: FeedSelection = .both
    @Previewable @State var morningFeed: Date = .eightAM
    @Previewable @State var eveningFeed: Date = .eightPM

    PetNotificationSelectionView(
        feedSelection: $feedSelection,
        morningFeed: $morningFeed,
        eveningFeed: $eveningFeed
    )
    .padding(.horizontal)
}
#endif
