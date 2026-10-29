//
//  PostureDailyChartView.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import SwiftUI

// MARK: - PostureDailyChart Component
struct PostureDailyChart: View {
    @StateObject private var viewModel = PostureDailyViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Posture")
                    .font(.title2.bold())

                Text("Daily statistics")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let today = viewModel.todayData {
                QualityRing(value: today.averageQuality, lineWidth: 18)
                    .frame(width: 180, height: 180)
                    .overlay {
                        VStack(spacing: 2) {
                            Text(today.averageQuality / 100, format: .percent.precision(.fractionLength(0)))
                                .font(.largeTitle.bold())
                                .fontDesign(.rounded)
                                .monospacedDigit()

                            Text("Quality")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                HStack(spacing: 8) {
                    ForEach(PostureCategory.allCases) { category in
                        let hours = today.hours(for: category)
                        CategoryTile(
                            category: category,
                            detail: Text("\(hours, format: .number.precision(.fractionLength(1)))h · \(hours / today.totalHours, format: .percent.precision(.fractionLength(0)))")
                        )
                    }
                }

                Divider()

                HStack {
                    StatView(title: "Hours", value: today.totalHours.formatted(.number.precision(.fractionLength(1))), icon: "clock.fill")
                    StatView(title: "Quality", value: (today.averageQuality / 100).formatted(.percent.precision(.fractionLength(0))), icon: "chart.bar.fill")
                    StatView(title: "Sessions", value: today.sessions.count.formatted(), icon: "list.bullet")
                }
            } else {
                ContentUnavailableView(
                    "No data for today",
                    systemImage: "airpodspro",
                    description: Text("Wear your AirPods to start tracking your posture")
                )
            }
        }
        .card()
    }
}

#Preview {
    ScrollView {
        PostureDailyChart()
            .padding()
    }
}
