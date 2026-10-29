//
//  PostureSessionChart.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import SwiftUI
import Charts

struct PostureSessionChart: View {
    @StateObject private var viewModel = PostureViewModel()

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Posture Analysis")
                        .font(.title2.bold())

                    Text("Weekly statistics")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Chart {
                    ForEach(viewModel.sessionData) { day in
                        ForEach(PostureCategory.allCases) { category in
                            BarMark(
                                x: .value("Day", String(day.day.prefix(3))),
                                y: .value("Hours", day.hours(for: category))
                            )
                            .foregroundStyle(category.color.gradient)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(Int(hours))h")
                            }
                        }
                    }
                }
                .frame(height: 220)

                HStack(spacing: 8) {
                    ForEach(PostureCategory.allCases) { category in
                        CategoryTile(
                            category: category,
                            detail: Text("\(viewModel.categoryCounts[category] ?? 0) sess.")
                        )
                    }
                }

                Divider()

                HStack {
                    StatView(title: "Hours", value: viewModel.totalHours.formatted(.number.precision(.fractionLength(1))), icon: "clock.fill")
                    StatView(title: "Quality", value: (viewModel.averageQuality / 100).formatted(.percent.precision(.fractionLength(0))), icon: "chart.bar.fill")
                    StatView(title: "Sessions", value: viewModel.totalSessions.formatted(), icon: "list.bullet")
                }
            }
            .card()

            VStack(alignment: .leading, spacing: 8) {
                Text("Days")
                    .font(.headline)
                    .padding(.leading, 4)

                VStack(spacing: 0) {
                    ForEach(viewModel.sessionData) { day in
                        Button {
                            viewModel.selectedDay = day
                        } label: {
                            DayRow(day: day)
                        }
                        .buttonStyle(.plain)

                        if day != viewModel.sessionData.last {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(Theme.cardBackground, in: .rect(cornerRadius: Theme.cardRadius))
            }
        }
        .sheet(item: $viewModel.selectedDay, content: SessionDetailsView.init)
    }
}

#Preview {
    ScrollView {
        PostureSessionChart()
            .padding()
    }
}
