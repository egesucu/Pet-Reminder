//
//  Row.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct Row: View {
    var imageName: String
    var content: String
    var type: NotificationType

    var body: some View {
        HStack(alignment: .center, spacing: .spacing8) {
            Image(systemName: imageName)
                .font(.system(size: .icon24))
            Text(content)
        }
        .bold()
        .foregroundStyle(.white)
        .padding(.spacing16)
        .glassEffect(
            .regular.tint(
                type == .morning ? .yellow  : .blue
            )
        )
    }
}

private struct FeedDayHeader: View {
    let date: Date
    let completedCount: Int
    let showsRelativeDate: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: .spacing12) {
            VStack(alignment: .leading, spacing: .spacing4) {
                if showsRelativeDate {
                    Text("Today", comment: "Date label for today's feeding record.")
                        .font(.headline)
                } else {
                    Text(date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                        .font(.headline)
                }

                Text(date, format: .dateTime.year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: .spacing8)

            Text(
                "\(completedCount) recorded",
                comment: "Number of completed feeding records for one day."
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, .spacing8)
            .padding(.vertical, .spacing4)
            .background(Color.secondary.opacity(0.1), in: Capsule())
        }
    }
}

struct Row: View {
    let type: NotificationType
    let time: Date

    var body: some View {
        HStack(spacing: .spacing12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: .spacing40, height: .spacing40)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: .radius10))

            VStack(alignment: .leading, spacing: .spacing4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Label {
                    Text("Completed", comment: "Status of a recorded feeding.")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .font(.caption)
                .foregroundStyle(.green)
            }

            Spacer(minLength: .spacing12)

            Text(time, format: .dateTime.hour().minute())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, .spacing8)
        .accessibilityElement(children: .combine)
    }

    private var title: LocalizedStringResource {
        type == .morning ? "Morning" : "Evening"
    }

    private var systemImage: String {
        type == .morning ? "sun.max.fill" : "moon.stars.fill"
    }

    private var tint: Color {
        type == .morning ? .orange : .indigo
    }
}

struct FeedHistoryEmptyState: View {
    let systemImage: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource

    var body: some View {
        VStack(spacing: .spacing12) {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundStyle(.secondary)

            VStack(spacing: .spacing4) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing24)
        .padding(.horizontal, .spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radius16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}
