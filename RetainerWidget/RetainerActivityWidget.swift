//
//  RetainerActivityWidget.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - RetainerActivityWidget

/// Live Activity widget for the Dynamic Island and Lock Screen.
///
/// Displays real-time timer progress with status colors and animated
/// progress bar that updates automatically via `timerInterval`.
@available(iOS 26.0, *)
struct RetainerActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RetainerActivityAttributes.self) { context in
            // Lock Screen/Banner UI
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "ring")
                        .foregroundColor(statusColor(for: context.state))
                        .font(.title3)
                    
                    VStack(alignment: .leading) {
                        Text("TrayOff")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(statusText(for: context.state))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if context.state.isRunning {
                        Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture, countsDown: false)
                            .monospacedDigit()
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor(for: context.state))
                    } else {
                        Text(TimeFormatter.formatSimplified(context.state.accumulatedTime))
                            .monospacedDigit()
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor(for: context.state))
                    }
                }
                .padding()
                
                // Progress Bar
                if context.state.isRunning {
                    ProgressView(timerInterval: context.state.effectiveStartDate...context.state.effectiveStartDate.addingTimeInterval(context.state.goal), countsDown: false) {
                        EmptyView()
                    } currentValueLabel: {
                        EmptyView()
                    }
                    .progressViewStyle(LinearProgressViewStyle(tint: statusColor(for: context.state)))
                    .frame(height: 6)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                } else {
                    // Static progress bar for paused state
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(statusColor(for: context.state))
                                .frame(width: min(geo.size.width, geo.size.width * progress(for: context.state)), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .environment(\.colorScheme, .dark)
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "ring")
                            .foregroundColor(statusColor(for: context.state))
                            .padding(.leading, 4)
                        Text("TrayOff")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isRunning {
                        Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture, countsDown: false)
                            .monospacedDigit()
                            .font(.title2)
                            .foregroundColor(statusColor(for: context.state))
                    } else {
                        Text(TimeFormatter.formatSimplified(context.state.accumulatedTime))
                            .monospacedDigit()
                            .font(.title2)
                            .foregroundColor(statusColor(for: context.state))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        if context.state.isRunning {
                            ProgressView(timerInterval: context.state.effectiveStartDate...context.state.effectiveStartDate.addingTimeInterval(context.state.goal), countsDown: false) {
                                EmptyView()
                            } currentValueLabel: {
                                EmptyView()
                            }
                            .progressViewStyle(LinearProgressViewStyle(tint: statusColor(for: context.state)))
                            .tint(statusColor(for: context.state))
                            .frame(height: 8)
                        } else {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(statusColor(for: context.state))
                                        .frame(width: min(geo.size.width, geo.size.width * progress(for: context.state)), height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        
                        Text(statusText(for: context.state))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            } compactLeading: {
                Image(systemName: "ring")
                    .foregroundColor(statusColor(for: context.state))
                    .padding(.leading, 4)
            } compactTrailing: {
                if context.state.isRunning {
                    Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                        .frame(width: 50)
                        .foregroundColor(statusColor(for: context.state))
                } else {
                    Text(TimeFormatter.formatSimplified(context.state.accumulatedTime))
                        .monospacedDigit()
                        .frame(width: 50)
                        .foregroundColor(statusColor(for: context.state))
                }
            } minimal: {
                Image(systemName: "ring")
                    .foregroundColor(statusColor(for: context.state))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func progress(for state: RetainerActivityAttributes.ContentState) -> Double {
        let current = state.isRunning 
            ? Date().timeIntervalSince(state.effectiveStartDate) 
            : state.accumulatedTime
            
        if state.goal <= 0 { return 0 }
        
        return min(1.0, current / state.goal)
    }
    
    func statusColor(for state: RetainerActivityAttributes.ContentState) -> Color {
        let current = state.isRunning 
            ? Date().timeIntervalSince(state.effectiveStartDate) 
            : state.accumulatedTime
            
        if current < state.goal {
            return .green
        } else if current < state.danger {
            return .yellow
        } else {
            return .red
        }
    }
    
    func statusText(for state: RetainerActivityAttributes.ContentState) -> String {
        let current = state.isRunning 
            ? Date().timeIntervalSince(state.effectiveStartDate) 
            : state.accumulatedTime
            
        if current < state.goal {
            return "On Track"
        } else if current < state.danger {
            return "Warning"
        } else {
            return "Over Limit"
        }
    }
}

// MARK: - TimeFormatter (Widget)

/// Time formatting helper for the Live Activity widget.
struct TimeFormatter {
    static func formatSimplified(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
