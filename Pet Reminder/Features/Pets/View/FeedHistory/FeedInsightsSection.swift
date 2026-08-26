//
//  FeedInsightsSection.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 26.08.2026.
//  Copyright © 2026 Ege Sucu. All rights reserved.
//

import Charts
import SwiftUI
import Shared

struct FeedInsightsSection: View {
    let records: [FeedDayRecord]

    @State private var isChartVisible = false

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("LAST 7 DAYS", comment: "Heading for feeding history statistics.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: .spacing20) {
                HStack(spacing: .spacing12) {
                    FeedStatistic(
                        value: completionRate.formatted(.percent.precision(.fractionLength(0))),
                        label: "Completion"
                    )

                    Divider()

                    FeedStatistic(
                        value: totalFeeds.formatted(),
                        label: "Feeds"
                    )

                    Divider()

                    FeedStatistic(
                        value: fullDayStreak.formatted(),
                        label: "Day streak"
                    )
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: .spacing4) {
                    Chart(recentDays) { day in
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Feeds", isChartVisible ? day.completedCount : 0)
                        )
                        .foregroundStyle(day.completedCount == 2 ? Color.green : Color.accentColor)
                        .cornerRadius(4)
                    }
                    .chartYScale(domain: 0...2)
                    .chartYAxis {
                        AxisMarks(values: [0, 1, 2])
                    }
                    .chartXAxis(.hidden)
                    .frame(height: 130)
                    .animation(.smooth(duration: 0.6), value: isChartVisible)
                    .animation(.smooth, value: recentDays.map(\.completedCount))
                    .onAppear {
                        withAnimation(.smooth(duration: 0.6)) {
                            isChartVisible = true
                        }
                    }
                    .accessibilityLabel("Feeds completed during the last seven days")

                    HStack(spacing: 0) {
                        ForEach(recentDays) { day in
                            Text(day.date, format: .dateTime.weekday(.narrow))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .accessibilityHidden(true)
                }
                .frame(height: 150)
            }
            .padding(.spacing16)
            .background(
                RoundedRectangle(cornerRadius: .radius16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
    }

    private var recentDays: [FeedInsightDay] {
        let recordsByDate = Dictionary(uniqueKeysWithValues: records.map {
            (calendar.startOfDay(for: $0.date), $0.completedCount)
        })
        let today = calendar.startOfDay(for: .now)

        return (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return nil
            }

            return FeedInsightDay(date: date, completedCount: recordsByDate[date, default: 0])
        }
    }

    private var totalFeeds: Int {
        recentDays.reduce(0) { $0 + $1.completedCount }
    }

    private var completionRate: Double {
        Double(totalFeeds) / Double(recentDays.count * 2)
    }

    private var fullDayStreak: Int {
        recentDays.reversed().prefix { $0.completedCount == 2 }.count
    }
}

private struct FeedInsightDay: Identifiable {
    let date: Date
    let completedCount: Int

    var id: Date { date }
}

private struct FeedStatistic: View {
    let value: String
    let label: LocalizedStringResource

    var body: some View {
        VStack(spacing: .spacing4) {
            Text(value)
                .font(.title3.weight(.bold))
                .contentTransition(.numericText())

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
