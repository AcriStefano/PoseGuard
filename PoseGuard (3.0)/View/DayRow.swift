//
//  DayRow.swift
//  PoseGuard (3.0)
//

import SwiftUI

/// Tappable summary of one day, leading to its session details.
struct DayRow: View {
    let day: DayData

    var body: some View {
        HStack(spacing: 16) {
            QualityRing(value: day.averageQuality, lineWidth: 5)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(day.day)
                    .font(.headline)

                Text("^[\(day.sessions.count) session](inflect: true) · \(day.totalHours, format: .number.precision(.fractionLength(1)))h")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(day.averageQuality / 100, format: .percent.precision(.fractionLength(0)))
                .font(.headline)
                .fontDesign(.rounded)
                .monospacedDigit()

            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
        }
        .padding()
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
