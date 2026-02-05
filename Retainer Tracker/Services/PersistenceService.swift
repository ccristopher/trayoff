//
//  PersistenceService.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation

/// Represents the persisted state of the timer.
///
/// Used to save and restore timer state across app launches and
/// to share state with the widget extension via App Groups.
struct TimerState: Codable {
    /// The timer's start time as seconds since reference date.
    var startTime: Double
    
    /// Whether the timer was running when saved.
    var isRunning: Bool
    
    /// Total accumulated time in seconds from previous sessions today.
    var accumulatedTime: Double
    
    /// The date of the last timer reset (used for midnight rollover).
    var lastResetDate: Date
    
    /// When the current reminder countdown started, if any.
    var reminderStartTime: Date?
    
    /// When the current timer session started, if any.
    var currentSessionStart: Date?
    
    /// User's goal threshold in seconds.
    var goal: Double?
    
    /// User's danger threshold in seconds.
    var danger: Double?
}

// MARK: - Protocol

/// Protocol for timer state persistence operations.
protocol TimerPersistenceServiceProtocol {
    /// Saves the current timer state.
    /// - Parameter state: The timer state to persist.
    func saveTimerState(_ state: TimerState)
    
    /// Loads the previously saved timer state.
    /// - Returns: The saved state, or nil if none exists.
    func loadTimerState() -> TimerState?
}

// MARK: - Implementation

/// Service for persisting timer state using UserDefaults with App Groups.
///
/// Uses a shared App Group container to allow the widget extension
/// to read timer state for display.
class TimerPersistenceService: TimerPersistenceServiceProtocol {
    
    // MARK: - Properties
    
    private let defaults: UserDefaults
    private let timerStateKey = "timerState"
    private let suiteName = "group.com.TrayOff.shared"

    // MARK: - Initialization
    
    init() {
        if let sharedDefaults = UserDefaults(suiteName: suiteName) {
            self.defaults = sharedDefaults
        } else {
            self.defaults = UserDefaults.standard
        }
        
        migrateIfNeeded()
    }

    // MARK: - Public Methods
    
    func saveTimerState(_ state: TimerState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: timerStateKey)
        }
    }
    
    func loadTimerState() -> TimerState? {
        guard let data = defaults.data(forKey: timerStateKey),
              let state = try? JSONDecoder().decode(TimerState.self, from: data) else {
            return nil
        }
        return state
    }
    
    // MARK: - Private Methods
    
    /// Migrates timer state from standard UserDefaults to shared container.
    private func migrateIfNeeded() {
        let standard = UserDefaults.standard
        
        if standard.object(forKey: timerStateKey) != nil && defaults.object(forKey: timerStateKey) == nil {
            if let data = standard.data(forKey: timerStateKey) {
                defaults.set(data, forKey: timerStateKey)
            }
        }
    }
}
