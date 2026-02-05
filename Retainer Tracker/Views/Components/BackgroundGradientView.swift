//
//  BackgroundGradientView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI

/// A background gradient view that animates based on timer state.
///
/// Fades in when the timer is running and fades out when stopped.
/// The gradient color is based on the current progress status.
struct BackgroundGradientView: View {
    
    // MARK: - Properties
    
    /// Whether the timer is currently running.
    let isRunning: Bool
    
    /// The base color for the gradient (typically the status color).
    let baseColor: Color
    
    // MARK: - Private Properties
    
    private var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: baseColor.opacity(0.32), location: 0),
                .init(color: baseColor.opacity(0.20), location: 0.1),
                .init(color: baseColor.opacity(0.15), location: 0.2),
                .init(color: baseColor.opacity(0.10), location: 0.4),
                .init(color: baseColor.opacity(0.02), location: 1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        gradient
            .accessibilityLabel("Animated background gradient")
            .ignoresSafeArea()
            .opacity(isRunning ? 1.0 : 0.0)
            .animation(.easeIn(duration: AppConfig.Animation.slow), value: isRunning)
    }
}

// MARK: - Preview

#Preview {
    BackgroundGradientView(isRunning: true, baseColor: .blue)
}