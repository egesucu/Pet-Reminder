//
//  PreviousFeedsSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 31.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PreviousFeedsSection: View {
    let records: [FeedDayRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("PREVIOUS", comment: "Heading for previous feeding history records.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if records.isEmpty {
                FeedHistoryEmptyState(
                    systemImage: "clock.arrow.circlepath",
                    title: "No previous feeds",
                    message: "Older completed feeds will appear here."
                )
            } else {
                VStack(spacing: .spacing12) {
                    ForEach(records) { record in
                        FeedDayCard(record: record, showsRelativeDate: false)
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    PreviousFeedsSection(
        records: FeedDayRecord.makeRecords(from: Feed.previews)
    )
}
#endif
