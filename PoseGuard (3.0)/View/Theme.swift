//
//  Theme.swift
//  PoseGuard (3.0)
//

import SwiftUI

/// Shared design tokens, so every screen feels like part of the same app.
enum Theme {
    static let cardRadius: CGFloat = 24
    static let spring = Animation.spring(duration: 0.45, bounce: 0.25)

    // Original PoseGuard palette, on a black, always-dark interface.
    static let brandGreen = Color(red: 0x4C / 255, green: 0xEF / 255, blue: 0x7E / 255)
    static let gold = Color(red: 1, green: 0xD7 / 255, blue: 0)
    static let alertRed = Color(red: 1, green: 0x52 / 255, blue: 0x52 / 255)
    static let cardBackground = Color(red: 0x12 / 255, green: 0x12 / 255, blue: 0x12 / 255)
}

extension View {
    /// Rounded card on the original near-black card color.
    func card() -> some View {
        padding()
            .frame(maxWidth: .infinity)
            .background(Theme.cardBackground, in: .rect(cornerRadius: Theme.cardRadius))
    }
}
