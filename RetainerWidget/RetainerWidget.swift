//
//  RetainerWidget.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import WidgetKit
import SwiftUI

// MARK: - TimerState

/// Duplicate of the struct in the main app for widget access.
struct TimerState: Codable {
    var startTime: Double
    var isRunning: Bool
    var accumulatedTime: Double
    var lastResetDate: Date
    var reminderStartTime: Date?
    var currentSessionStart: Date?
    var goal: Double?
    var danger: Double?
}

// MARK: - TimelineProvider

/// Provides timeline entries for the home screen widget.
struct Provider: TimelineProvider {
    let suiteName = "group.com.TrayOff.shared"
    let timerStateKey = "timerState"
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), accumulatedTime: 3600, isRunning: false, status: .onTrack, goal: 3600, danger: 7200)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = loadEntry()
        
        // Refresh every 15 minutes or when reloadAllTimelines is called
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadEntry() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        
        var accumulatedTime: Double = 0
        var isRunning = false
        var goal: Double = 3600
        var danger: Double = 7200
        
        if let data = defaults?.data(forKey: timerStateKey),
           let state = try? JSONDecoder().decode(TimerState.self, from: data) {
            
            accumulatedTime = state.accumulatedTime
            
            if let savedGoal = state.goal { goal = savedGoal }
            if let savedDanger = state.danger { danger = savedDanger }
            
            if state.isRunning {
                let now = Date()
                let start = Date(timeIntervalSinceReferenceDate: state.startTime)
                accumulatedTime += now.timeIntervalSince(start)
                isRunning = true
            }
            
            // Check if reset needed (if saved state is from yesterday)
            if !Calendar.current.isDate(state.lastResetDate, inSameDayAs: Date()) {
                accumulatedTime = 0
                isRunning = false
            }
        }
        
        var status: WidgetStatus = .onTrack
        if accumulatedTime > danger {
            status = .overLimit
        } else if accumulatedTime > goal {
            status = .warning
        }
        
        return SimpleEntry(
            date: Date(),
            accumulatedTime: accumulatedTime,
            isRunning: isRunning,
            status: status,
            goal: goal,
            danger: danger
        )
    }
}

// MARK: - WidgetStatus

/// Represents the current goal compliance status.
enum WidgetStatus {
    case onTrack
    case warning
    case overLimit
    
    var color: Color {
        switch self {
        case .onTrack: return .green
        case .warning: return .yellow
        case .overLimit: return .red
        }
    }
    
    var label: String {
        switch self {
        case .onTrack: return "On Track"
        case .warning: return "Warning"
        case .overLimit: return "Over Limit"
        }
    }
}

// MARK: - SimpleEntry

/// Timeline entry containing widget display data.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let accumulatedTime: Double
    let isRunning: Bool
    let status: WidgetStatus
    let goal: Double
    let danger: Double
}

// MARK: - RetainerWidgetEntryView

/// The visual content of the home screen widget.
struct RetainerWidgetEntryView: View {
    var entry: Provider.Entry
    
    var goalText: String {
        let hours = Int(entry.goal) / 3600
        if hours > 0 {
            return "Goal: < \(hours)h"
        } else {
            let minutes = Int(entry.goal) / 60
            return "Goal: < \(minutes)m"
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("TIME OFF")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(0)
            }
            
            Spacer()
            
            ZStack {
                WidgetActivityRing(
                    progress: entry.accumulatedTime,
                    goal: entry.goal,
                    danger: entry.danger,
                    ringColor: entry.status.color
                )
                .frame(width: 100, height: 100)
                
                VStack(spacing: 2) {
                    Text(HomeWidgetTimeFormatter.formatSimplified(entry.accumulatedTime))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.5)
                    
                    Text(entry.status.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(goalText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - RetainerWidget

/// Home screen widget configuration.
@available(iOS 26.0, *)
struct RetainerWidget: Widget {
    let kind: String = "RetainerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RetainerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TrayOff")
        .description("Track your time off.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - HomeWidgetTimeFormatter

/// Time formatting helper for the widget.
struct HomeWidgetTimeFormatter {
    static func formatSimplified(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else {
            return String(format: "%d:%02d", minutes, Int(totalSeconds) % 60)
        }
    }
}

// MARK: - WidgetActivityRing

/// Activity ring component for the widget display.
struct WidgetActivityRing: View {
    var progress: Double
    var goal: Double
    var danger: Double
    var ringColor: Color
    
    private enum RingPhase {
        case green, yellow, red
    }
    
    private var ringPhase: RingPhase {
        if progress <= goal { return .green }
        else if progress <= danger { return .yellow }
        else { return .red }
    }
    
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
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .opacity(0.2)
                .foregroundStyle(ringColor)
            
            Circle()
                .trim(from: 0, to: trimTo)
                .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                .foregroundStyle(ringColor)
                .rotationEffect(.degrees(270.0))
        }
    }
}
