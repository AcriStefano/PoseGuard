//
//  DayData.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation

struct DayData: Identifiable, Equatable {
    let id = UUID()
    let day: String
    let sessions: [PostureSession]

    // Ore raggruppate per categoria
    func hours(for category: PostureCategory) -> Double {
        sessions.filter { $0.category == category }.reduce(0) { $0 + $1.duration }
    }

    // Statistiche giornaliere
    var totalHours: Double {
        sessions.reduce(0) { $0 + $1.duration }
    }

    var averageQuality: Double {
        let weightedSum = sessions.reduce(0) { $0 + (Double($1.avgQuality) * $1.duration) }
        return sessions.isEmpty ? 0 : weightedSum / totalHours
    }

    // Implementazione di Equatable
    static func == (lhs: DayData, rhs: DayData) -> Bool {
        lhs.id == rhs.id && lhs.day == rhs.day
    }
}
