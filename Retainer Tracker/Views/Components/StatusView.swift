//
//  StatusView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI

/// Displays the elapsed time in a large, prominent format.
///
/// Shows "Off for" label with the formatted duration below.
/// The text opacity is reduced when the timer is running for visual feedback.
struct StatusView: View {
    
    // MARK: - Properties
    
    /// Current progress in seconds.
    let progress: Double
    
    /// Whether the timer is currently running.
    let isRunning: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text("Off for")
                .opacity(isRunning ? 0.8 : 1.0)
                .font(.title3)
                .fontWeight(.medium)
            Text(TimeFormatter.formatSimplified(progress))
                .font(.system(size: 60))
                .fontWeight(.medium)
                .opacity(isRunning ? 0.8 : 1.0)
                .accessibilityLabel("Time off: \(TimeFormatter.formatDescription(progress))")
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StatusView(progress: 3599, isRunning: false)
        StatusView(progress: 3600, isRunning: false)
        StatusView(progress: 3665, isRunning: true)
    }
}