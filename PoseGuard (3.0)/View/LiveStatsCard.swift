//
//  LiveStatsCard.swift
//  PoseGuard (3.0)
//

import SwiftUI

/// Session timer plus live head tilt, shown while tracking.
struct LiveStatsCard: View {
    let startDate: Date
    let pitch: Double
    let roll: Double

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 4) {
                Text(startDate, style: .timer)
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .frame(height: 58)

                Text("Session")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            TiltGauge(title: "Forward", angle: pitch)
            TiltGauge(title: "Sideways", angle: roll)
        }
        .card()
    }
}

#Preview {
    LiveStatsCard(startDate: .now.addingTimeInterval(-95), pitch: 8, roll: -19)
        .padding()
        .background(.black)
        .preferredColorScheme(.dark)
}
