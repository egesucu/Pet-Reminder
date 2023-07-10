//
//  PetNotificationSelectionView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 23.04.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI

struct PetNotificationSelectionView: View {

    @Binding var dayType: FeedTimeSelection
    @Binding var morningFeed: Date
    @Binding var eveningFeed: Date

    var body: some View {
        VStack {
            Text("feed_time_title")
                .font(.title2).bold()
                .padding(.vertical)
            Picker(selection: $dayType, label: Text("feed_time_title")) {
                Text("feed_selection_both")
                    .tag(FeedTimeSelection.both)
                Text("feed_selection_morning")
                    .tag(FeedTimeSelection.morning)
                Text("feed_selection_evening")
                    .tag(FeedTimeSelection.evening)
            }
            .pickerStyle(.segmented)
            .animation(.easeOut(duration: 0.8), value: dayType)

            notificationType()
                .animation(.easeOut(duration: 0.8), value: dayType)
                .padding(.all)
        }

    }

    @ViewBuilder func notificationType() -> some View {
        switch dayType {
        case .morning:
            morningView
        case .evening:
            eveningView
        default:
            bothView
        }
    }

    var morningView: some View {
        HStack {
            Image(.morning)
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_morning",
                       selection: $morningFeed,
                       in: ...eveningFeed.addingTimeInterval(60),
                       displayedComponents: .hourAndMinute)

        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)

    }

    var eveningView: some View {
        HStack {
            Image(.evening)
                .resizable()
                .frame(maxWidth: 100, maxHeight: 80)
                .cornerRadius(15)
            Spacer()
            DatePicker("feed_selection_evening",
                       selection: $eveningFeed,
                       in: morningFeed.addingTimeInterval(60)...,
                       displayedComponents: .hourAndMinute)
        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)
    }

    var bothView: some View {
        VStack {
            morningView
                .padding(.vertical)
            eveningView
        }
        .animation(.easeOut(duration: 0.8), value: dayType)
        .transition(.identity)
    }
}

#Preview {
    PetNotificationSelectionView(
        dayType: .constant(
            .both
        ),
        morningFeed: .constant(
            .now
        ),
        eveningFeed: .constant(
            .now
        )
    )
}
