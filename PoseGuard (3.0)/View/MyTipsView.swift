//
//  MyTipsView.swift
//  PoseGuard (3.0)
//
//  Created by Acri Stefano on 10/03/25.
//

import SwiftUI

struct MyTipsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TipsViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.tips) { tip in
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tip.title)
                            .font(.headline)

                        Text(tip.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: tip.icon)
                        .foregroundStyle(.tint)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Tips")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    MyTipsView()
}
