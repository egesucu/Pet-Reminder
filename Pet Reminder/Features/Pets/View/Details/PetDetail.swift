//
//  PetDetail.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.07.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import Shared
import SwiftData

struct PetDetail: View {

    private enum HistoryDestination: Hashable, Identifiable {
        case feedHistory
        case vaccines

        var id: Self { self }
    }

    let pet: Pet
    @State private var historyDestination: HistoryDestination?

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing24) {
                header
                dailyCareCard
                historyActions
            }
            .padding(.horizontal, .spacing20)
            .padding(.top, .spacing16)
            .padding(.bottom, .spacing32)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(Text("pet_name_title \(pet.name)"))
        .navigationDestination(item: $historyDestination) { destination in
            switch destination {
            case .feedHistory:
                FeedHistory(feeds: pet.feeds)
            case .vaccines:
                VaccineHistory(pet: pet)
            }
        }
    }

}

private extension PetDetail {

    var yellowGradient: LinearGradient {
        LinearGradient(
            colors: [.yellow, .yellow.opacity(0.55), .yellow.opacity(0.25)],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }

    var header: some View {
        HStack {
            Spacer()
            CircleImage(
                avatarSize: .avatar120,
                imageData: pet.image,
                kind: pet.kind
            )
            Spacer()
        }
    }

    var dailyCareCard: some View {
        VStack(alignment: .leading, spacing: .spacing16) {

            VStack(alignment: .leading, spacing: .spacing8) {
                Label("Today's care", systemImage: "pawprint.fill")
                    .font(.headline)
                    .foregroundStyle(Color.label)

                Text(pet.feedSelection.definition)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

            }

            FeedList(pet: pet)
                .frame(maxWidth: .infinity, minHeight: .feedCardHeight100)
                .padding(.vertical, .spacing8)

            Divider()

            Label(nextFeedSummary, systemImage: nextFeedIcon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(nextFeedColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.spacing20)
        .background(
            RoundedRectangle(cornerRadius: .radius16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: .radius16)
                .stroke(yellowGradient, lineWidth: 2)
        }
    }

    var historyActions: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("History")
                .font(.headline)
                .foregroundStyle(Color.label)

            VStack(spacing: .spacing8) {
                detailActionButton(
                    title: .feedHistoryTitle,
                    subtitle: String(localized: "Review feeding records"),
                    systemImage: "fork.knife",
                    tint: .accentColor
                ) {
                    Logger
                        .pets
                        .info("PR: Feed History Tapped, pet name: \(pet.name)")
                    historyDestination = .feedHistory
                }

                detailActionButton(
                    title: .vaccinesTitle,
                    subtitle: String(localized: "Review vaccine records"),
                    systemImage: "syringe.fill",
                    tint: .blue
                ) {
                    Logger
                        .pets
                        .info("PR: Vaccine History Tapped")
                    historyDestination = .vaccines
                }
            }
        }
    }

    func detailActionButton(
        title: LocalizedStringResource,
        subtitle: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: .spacing12) {
                Image(systemName: systemImage)
                    .font(.system(size: .icon20, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: .minimum, height: .minimum)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: .radius10))

                VStack(alignment: .leading, spacing: .spacing4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.label)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: .spacing12)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.spacing16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .radius16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }

    var todayFeed: Feed? {
        pet.feeds?
            .first { Calendar.current.isDateInToday($0.feedDate ?? .now) }
    }

    var isMorningFed: Bool {
        todayFeed?.morningFed ?? false
    }

    var isEveningFed: Bool {
        todayFeed?.eveningFed ?? false
    }

    var nextFeedSummary: String {
        if isFeedComplete {
            return String(localized: "All needs complete")
        }

        let feedName = switch pet.feedSelection {
        case .morning:
            String(localized: "Morning feed")
        case .evening:
            String(localized: "Evening feed")
        case .both:
            isMorningFed ? String(localized: "Evening feed") : String(localized: "Morning feed")
        }

        return "\(String(localized: "Next")): \(feedName)"
    }

    var nextFeedIcon: String {
        isFeedComplete ? "checkmark.circle.fill" : "clock.fill"
    }

    var nextFeedColor: Color {
        isFeedComplete ? .green : .orange
    }

    var isFeedComplete: Bool {
        switch pet.feedSelection {
        case .morning:
            isMorningFed
        case .evening:
            isEveningFed
        case .both:
            isMorningFed && isEveningFed
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PetDetail(
            pet: .preview
        )
        .modelContainer(DataController.previewContainer)
    }
}
#endif
