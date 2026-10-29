//
//  Posturesession.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import Foundation

struct PostureSession: Identifiable, Equatable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let duration: Double
    let avgQuality: Int
    let category: PostureCategory

    // Implementazione di Equatable
    static func == (lhs: PostureSession, rhs: PostureSession) -> Bool {
        lhs.id == rhs.id
    }
}
