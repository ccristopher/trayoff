//
//  ActivityRing.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI

/// A circular progress ring that changes color based on progress thresholds.
///
/// The ring counts down from full to empty as progress increases toward each threshold.
/// The color changes from green (under goal) to yellow (under danger) to red (over danger).
struct ActivityRing: View {
    
    // MARK: - Properties
    
    /// Current progress in seconds.
    var progress: Double
    
    /// Goal threshold in seconds (green → yellow transition).
    var goal: Double
    
    /// Danger threshold in seconds (yellow → red transition).
    var danger: Double
    
    /// The color to display the ring.
    var ringColor: Color
    
    @State private var isVisible = false
    @State private var hasAppeared = false
    
    // MARK: - Private Types
    
    private enum RingPhase {
        case green, yellow, red
    }
    
    // MARK: - Computed Properties
    
    private var ringPhase: RingPhase {
        if progress <= goal { return .green }
        else if progress <= danger { return .yellow }
        else { return .red }
    }
    
    /// Calculates the ring trim amount based on current phase.
    /// The ring counts down from full (1.0) to empty (0.0) as progress increases.
    private var trimTo: CGFloat {
        switch ringPhase {
        case .green:
            let remaining = 1.0 - min(progress / max(goal, 0.01), 1.0)
            return CGFloat(remaining)
        case .yellow:
            let yellowProgress = (progress - goal) / max((danger - goal), 0.01)
            let remaining = 1.0 - min(yellowProgress, 1.0)
            return CGFloat(remaining)
        case .red:
            let redProgress = (progress - danger) / max((progress > danger ? progress - danger : 1.0), 0.01)
            let remaining = 1.0 - min(redProgress, 1.0)
            return CGFloat(remaining)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(lineWidth: 10)
                .background(Circle().fill(.ultraThinMaterial))
                .opacity(0.2)
                .foregroundStyle(ringColor)
            
            // Animated foreground ring
            Circle()
                .trim(from: 0, to: trimTo)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundStyle(ringColor)
                .rotationEffect(.degrees(270.0))
                .animation(.easeInOut(duration: AppConfig.Animation.standard), value: progress)
        }
        .opacity(hasAppeared ? 1 : (isVisible ? 1 : 0))
        .onAppear {
            if !hasAppeared {
                withAnimation(.easeInOut(duration: AppConfig.Animation.slow)) {
                    isVisible = true
                }
                hasAppeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ActivityRing(progress: 3600, goal: 7200, danger: 14400, ringColor: .blue)
}