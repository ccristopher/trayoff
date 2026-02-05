//
//  TimerEngine.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Protocol

/// Protocol defining core timer operations.
protocol TimerEngineProtocol: ObservableObject {
    /// Whether the timer is currently running.
    var isRunning: Bool { get }
    
    /// Total accumulated time in seconds from completed sessions today.
    var accumulatedTime: Double { get }
    
    /// Current progress including active session time.
    var currentProgress: Double { get }

    /// Starts the timer.
    func start()
    
    /// Stops the timer and accumulates elapsed time.
    func stop()
    
    /// Resets the timer to zero.
    func reset()
}

// MARK: - Implementation

/// Core timer engine that tracks elapsed time.
///
/// Uses system uptime for timing to remain accurate even when the
/// system clock changes. Updates `currentProgress` at a configurable
/// interval (default 100ms) while running.
class TimerEngine: TimerEngineProtocol {
    
    // MARK: - Published Properties
    
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var accumulatedTime: Double = 0.0
    @Published private(set) var currentProgress: Double = 0.0

    // MARK: - Properties
    
    /// When the current session started (wall clock time for persistence).
    private(set) var timerStartTime: Date = Date()
    
    /// System uptime when the timer started (for drift-free timing).
    private var uptimeStart: TimeInterval = 0.0
    
    /// Background task that updates currentProgress.
    private var timerTask: Task<Void, Never>?

    // MARK: - Public Methods
    
    /// Toggles the timer between running and stopped states.
    func toggle() {
        withAnimation {
            isRunning.toggle()
        }
        if isRunning {
            start()
        } else {
            stop()
        }
    }

    func start() {
        isRunning = true
        timerStartTime = Date()
        uptimeStart = ProcessInfo.processInfo.systemUptime
        startTimerTask()
    }

    func stop() {
        isRunning = false
        stopTimerTask()
        let uptimeNow = ProcessInfo.processInfo.systemUptime
        accumulatedTime += uptimeNow - uptimeStart
        currentProgress = accumulatedTime
    }

    func reset() {
        stopTimerTask()
        timerStartTime = Date()
        uptimeStart = 0.0
        isRunning = false
        accumulatedTime = 0.0
        currentProgress = 0.0
    }

    /// Pauses the timer without stopping (for app backgrounding).
    func pause() {
        if isRunning {
            stopTimerTask()
            let uptimeNow = ProcessInfo.processInfo.systemUptime
            accumulatedTime += uptimeNow - uptimeStart
            uptimeStart = uptimeNow
            timerStartTime = Date()
        }
    }

    /// Resumes the timer after returning to foreground.
    func resume() {
        if isRunning {
            let now = Date()
            let timePassed = now.timeIntervalSince(timerStartTime)
            
            accumulatedTime += timePassed
            timerStartTime = now
            
            uptimeStart = ProcessInfo.processInfo.systemUptime
            startTimerTask()
        } else {
            currentProgress = accumulatedTime
        }
    }

    /// Sets the accumulated time (used when recalculating from sessions).
    /// - Parameter time: The new accumulated time in seconds.
    func setAccumulatedTime(_ time: Double) {
        accumulatedTime = time
        currentProgress = accumulatedTime
    }

    /// Restores timer state from persisted values.
    /// - Parameters:
    ///   - startTime: Persisted start time as seconds since reference date.
    ///   - isRunning: Whether the timer was running when saved.
    ///   - accumulatedTime: Previously accumulated time in seconds.
    func setInitialState(startTime: Double, isRunning: Bool, accumulatedTime: Double) {
        self.timerStartTime = Date(timeIntervalSinceReferenceDate: startTime)
        self.isRunning = isRunning
        self.accumulatedTime = accumulatedTime
        
        if isRunning {
            // Restoring a running state: calculate elapsed time since save.
            let now = Date()
            let timePassed = now.timeIntervalSince(self.timerStartTime)
            self.accumulatedTime += timePassed
            self.timerStartTime = now
            self.uptimeStart = ProcessInfo.processInfo.systemUptime
            self.currentProgress = self.accumulatedTime
        } else {
            self.currentProgress = accumulatedTime
        }
    }

    // MARK: - Private Methods
    
    private func startTimerTask() {
        stopTimerTask()
        timerTask = Task {
            while !Task.isCancelled && isRunning {
                let uptimeNow = ProcessInfo.processInfo.systemUptime
                await MainActor.run {
                    self.currentProgress = self.accumulatedTime + (uptimeNow - self.uptimeStart)
                }
                try? await Task.sleep(for: .milliseconds(Int(AppConfig.Timer.updateInterval * 1000)))
            }
        }
    }

    private func stopTimerTask() {
        timerTask?.cancel()
        timerTask = nil
    }
}
