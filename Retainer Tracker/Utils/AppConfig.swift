//
//  AppConfig.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI

/// Application-wide configuration constants.
///
/// Contains all configurable values for timer settings, persistence keys,
/// UI dimensions, and animation durations.
enum AppConfig {
    
    // MARK: - Timer Settings
    
    /// Timer-related configuration values.
    enum Timer {
        /// Default goal threshold in seconds (2 hours).
        static let defaultGoal: Double = 7200.0
        
        /// Default danger threshold in seconds (4 hours).
        static let defaultDanger: Double = 14400.0
        
        /// Timer update interval in seconds (100ms).
        static let updateInterval: TimeInterval = 0.1
    }
    
    // MARK: - Persistence Keys
    
    /// UserDefaults keys for persistence.
    enum Persistence {
        static let timerStartTimeKey = "timerStartTime"
        static let timerIsRunningKey = "timerIsRunning"
        static let accumulatedTimeKey = "accumulatedTime"
        static let lastResetDateKey = "lastResetDate"
        static let sessionsKey = "timerSessions"
        static let reminderStartTimeKey = "reminderStartTime"
        static let selectedReminderKey = "selectedReminder"
        static let currentSessionStartKey = "currentSessionStart"
    }
    
    // MARK: - UI Constants
    
    /// UI dimension constants.
    enum UI {
        static let ringSize: CGFloat = 260
        static let defaultSpacing: CGFloat = 16
        static let buttonIconSize: CGFloat = 25
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
    }
    
    // MARK: - Animation Durations
    
    /// Animation timing constants.
    enum Animation {
        static let standard: Double = 0.3
        static let slow: Double = 0.75
        static let fast: Double = 0.2
    }
}
