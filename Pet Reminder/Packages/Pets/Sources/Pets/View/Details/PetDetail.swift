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
import SharedUI
import PetCare
import SwiftData
#if DEBUG
import PreviewSupport
#endif

struct PetDetail: View {

    let pet: Pet
    var historyRequest: PetHistoryRequest? = nil
    @State private var historyDestination: PetHistoryDestination?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PetCareService.self) private var careService
    @State private var careSession: PetCareSession?

    private var feedingPet: Pet { careSession?.pet ?? pet }

    var body: some View {
        ScrollView {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: .spacing24) {
                    VStack(alignment: .leading, spacing: .spacing24) {
                        header
                        dailyCareCard
                    }
                    .frame(minWidth: .minimumDetailPane, maxWidth: .infinity)

                    Divider()

                    historyActions
                        .frame(minWidth: .minimumDetailPane, maxWidth: .infinity)
                }

                VStack(alignment: .leading, spacing: .spacing24) {
                    header
                    dailyCareCard
                    historyActions
                }
            }
            .padding(.horizontal, .spacing20)
            .padding(.top, .spacing16)
            .padding(.bottom, .spacing32)
        }
        .scrollIndicators(.hidden)
        .onChange(of: historyRequest, initial: true) { _, request in
            if let request, request.petID == pet.intentID { historyDestination = request.destination }
        }
        .navigationTitle(Text(SharedStrings.resource("pet_name_title \(pet.name)")))
        .onChange(of: careService.revision, initial: true) { _, _ in refreshCare() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshCare() }
        }
        .onReceive(NotificationCenter.default.publisher(for: ModelContext.didSave)) { _ in
            refreshCare()
        }
        .task {
            #if DEBUG
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("--store-screenshots"),
               let index = arguments.firstIndex(of: "--screenshot-screen"),
               arguments.indices.contains(index + 1),
               arguments[index + 1] == "history" {
                historyDestination = .feedHistory
            }
            #endif
        }
        .navigationDestination(item: $historyDestination) { destination in
            switch destination {
            case .feedHistory:
                FeedHistory(feeds: feedingPet.feeds, feedSelection: feedingPet.feedSelection)
            case .vaccines:
                VaccineHistory(pet: pet)
            }
        }
    }

}

private extension PetDetail {

    func refreshCare() {
        guard let id = pet.intentID else { return }
        let session = careSession ?? PetCareSession(container: modelContext.container)
        do {
            try session.reload(id: id)
            careSession = session
        } catch {
            Logger.feed.error("Failed to refresh feeding data: \(error.localizedDescription)")
        }
    }

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

            Label(SharedStrings.resource("Today's care"), systemImage: "pawprint.fill")
                .font(.headline)
                .foregroundStyle(Color.label)

            FeedList(pet: feedingPet)
                .environment(\.modelContext, careSession?.context ?? modelContext)
                .frame(maxWidth: .infinity, minHeight: .feedCardHeight100)
                .padding(.vertical, .spacing8)

            Divider()

            TimelineView(.periodic(from: .now, by: 60)) { _ in
                Label(nextFeedSummary, systemImage: nextFeedIcon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(nextFeedColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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
            Text(SharedStrings.resource("History"))
                .font(.headline)
                .foregroundStyle(Color.label)

            VStack(spacing: .spacing8) {
                detailActionButton(
                    title: SharedStrings.feedHistoryTitle,
                    subtitle: String(localized: "Review feeding records", bundle: SharedResources.bundle),
                    systemImage: "fork.knife",
                    tint: .accentColor
                ) {
                    Logger
                        .pets
                        .info("PR: Feed History Tapped, pet name: \(pet.name)")
                    historyDestination = .feedHistory
                }

                detailActionButton(
                    title: SharedStrings.vaccinesTitle,
                    subtitle: String(localized: "Review vaccine records", bundle: SharedResources.bundle),
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

    var isMorningFed: Bool {
        DailyFeeds.isFed(.morning, pet: feedingPet, at: .now)
    }

    var isEveningFed: Bool {
        DailyFeeds.isFed(.evening, pet: feedingPet, at: .now)
    }

    var nextFeedSummary: String {
        if isFeedComplete {
            return String(localized: "All needs complete", bundle: SharedResources.bundle)
        }

        let feedName = switch pet.feedSelection {
        case .morning:
            String(localized: "Morning feed", bundle: SharedResources.bundle)
        case .evening:
            String(localized: "Evening feed", bundle: SharedResources.bundle)
        case .both:
            if isMorningFed {
                String(localized: "Evening feed", bundle: SharedResources.bundle)
            } else {
                String(localized: "Morning feed", bundle: SharedResources.bundle)
            }
        }

        return "\(String(localized: "Next", bundle: SharedResources.bundle)): \(feedName)"
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

private extension CGFloat {
    static let minimumDetailPane: Self = 260
}

#if DEBUG
#Preview {
    NavigationStack {
        PetDetail(
            pet: .preview
        )
        .modelContainer(PreviewData.previewContainer)
        .environment(PetCareService(container: PreviewData.previewContainer))
    }
}
#endif

enum PetHistoryDestination: Hashable, Identifiable {
    case feedHistory, vaccines
    var id: Self { self }
}

struct PetHistoryRequest: Equatable {
    let destination: PetHistoryDestination
    let petID: UUID?
    let token = UUID()
}
