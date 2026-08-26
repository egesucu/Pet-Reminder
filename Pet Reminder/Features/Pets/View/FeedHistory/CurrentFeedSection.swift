//
//  CurrentFeedSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.08.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct CurrentFeedSection: View {
    let record: FeedDayRecord?

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("TODAY", comment: "Heading for today's feeding history section.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if let record {
                FeedDayCard(record: record, showsRelativeDate: true)
            } else {
                FeedHistoryEmptyState(
                    systemImage: "fork.knife.circle",
                    title: "No feeds recorded today",
                    message: "Completed feeds will appear here."
                )
            }
        }
    }
}
