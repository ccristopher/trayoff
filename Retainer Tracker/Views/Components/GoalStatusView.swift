//
//  GoalStatusView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI

/// Displays the current goal compliance status.
///
/// Shows "On Track", "Warning", or "Over Limit" based on current progress
/// relative to the user's goal and danger thresholds.
struct GoalStatusView: View {
    
    // MARK: - Properties
    
    /// Current progress in seconds.
    let progress: Double
    
    /// Goal threshold in seconds.
    let goal: Double
    
    /// Danger threshold in seconds.
    let danger: Double
    
    // MARK: - Computed Properties
    
    var statusText: String {
        if progress <= goal { return "On Track" }
        else if progress <= danger { return "Warning" }
        else { return "Over Limit" }
    }
    
    var statusColor: Color {
        if progress <= goal { return .green }
        else if progress <= danger { return .yellow }
        else { return .red }
    }
    
    var goalText: String {
        let hours = Int(goal) / 3600
        if hours > 0 {
            return "Goal: < \(hours)h"
        } else {
            let minutes = Int(goal) / 60
            return "Goal: < \(minutes)m"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(statusText)
                .font(.headline)
                .foregroundColor(statusColor)
            
            Text(goalText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview

#Preview {
    GoalStatusView(progress: 3000, goal: 3600, danger: 7200)
}
