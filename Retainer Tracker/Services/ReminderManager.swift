//
//  ReminderManager.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation
import Combine

// MARK: - Protocol

/// Protocol defining reminder countdown operations.
protocol ReminderManagerProtocol: ObservableObject {
    /// The selected reminder duration in minutes.
    var selectedReminder: Int { get set }
    
    /// Current countdown remaining in seconds.
    var reminderCountdown: Int { get }

    /// Starts a new reminder countdown.
    func startReminder()
    
    /// Stops and resets the reminder countdown.
    func stopReminder()
    
    /// Resumes an interrupted reminder from its original start time.
    /// - Parameter startTime: When the reminder was originally started.
    func resumeReminder(from startTime: Date)
}

// MARK: - Implementation

/// Manages the reminder countdown timer shown on the main button.
///
/// Uses system uptime for timing to remain accurate even when the
/// system clock changes. Coordinates with NotificationService to
/// schedule actual system notifications.
class ReminderManager: ReminderManagerProtocol {
    
    // MARK: - Properties
    
    /// The selected reminder duration in minutes. Persisted to UserDefaults.
    @Published var selectedReminder: Int = ReminderManager.loadSelectedReminder() {
        didSet {
            if !AppConfig.Timer.reminderOptions.contains(selectedReminder) {
                selectedReminder = AppConfig.Timer.defaultReminder
                return
            }
            UserDefaults.standard.set(selectedReminder, forKey: AppConfig.Persistence.selectedReminderKey)
        }
    }
    
    /// Current countdown remaining in seconds.
    @Published private(set) var reminderCountdown: Int = 0

    private var reminderCountdownTask: Task<Void, Never>?
    
    /// When the current reminder was started (for resume calculations).
    private(set) var reminderStartTime: Date?
    
    /// System uptime when the reminder started (for drift-free timing).
    private var uptimeStart: TimeInterval?

    // MARK: - Public Methods
    
    func startReminder() {
        NotificationService.shared.scheduleReminder(minutes: selectedReminder)
        reminderCountdown = selectedReminder * 60
        reminderStartTime = Date()
        uptimeStart = ProcessInfo.processInfo.systemUptime
        startReminderCountdown()
    }

    func stopReminder() {
        NotificationService.shared.cancelReminder()
        stopReminderCountdown()
        reminderCountdown = 0
        reminderStartTime = nil
        uptimeStart = nil
    }

    func resumeReminder(from startTime: Date) {
        let elapsedSeconds: Int
        
        if let uptimeStart = uptimeStart {
            let nowUptime = ProcessInfo.processInfo.systemUptime
            elapsedSeconds = Int(nowUptime - uptimeStart)
        } else {
            elapsedSeconds = Int(Date().timeIntervalSince(startTime))
        }
        
        reminderCountdown = max(0, selectedReminder * 60 - elapsedSeconds)
        
        if reminderCountdown > 0 {
            startReminderCountdown()
        } else {
            stopReminder()
        }
    }

    /// Restores reminder state from persisted values.
    /// - Parameter reminderStartTime: When the reminder was originally started.
    func setInitialState(reminderStartTime: Date?) {
        self.reminderStartTime = reminderStartTime
    }

    // MARK: - Private Methods

    private static func loadSelectedReminder() -> Int {
        let storedReminder = UserDefaults.standard.object(
            forKey: AppConfig.Persistence.selectedReminderKey
        ) as? Int ?? AppConfig.Timer.defaultReminder

        guard AppConfig.Timer.reminderOptions.contains(storedReminder) else {
            UserDefaults.standard.set(
                AppConfig.Timer.defaultReminder,
                forKey: AppConfig.Persistence.selectedReminderKey
            )
            return AppConfig.Timer.defaultReminder
        }

        return storedReminder
    }
    
    private func startReminderCountdown() {
        stopReminderCountdown()
        reminderCountdownTask = Task {
            while !Task.isCancelled && reminderCountdown > 0 {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    if let uptimeStart = self.uptimeStart {
                        let nowUptime = ProcessInfo.processInfo.systemUptime
                        let elapsed = Int(nowUptime - uptimeStart)
                        let totalSeconds = self.selectedReminder * 60
                        self.reminderCountdown = max(0, totalSeconds - elapsed)
                    } else {
                        self.reminderCountdown -= 1
                    }
                }
            }
            if reminderCountdown <= 0 {
                await MainActor.run {
                    self.stopReminder()
                }
            }
        }
    }

    private func stopReminderCountdown() {
        reminderCountdownTask?.cancel()
        reminderCountdownTask = nil
    }
}
