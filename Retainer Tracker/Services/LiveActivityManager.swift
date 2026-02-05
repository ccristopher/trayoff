//
//  LiveActivityManager.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation
import ActivityKit

/// Manages Live Activities for displaying timer status on Lock Screen and Dynamic Island.
///
/// Handles starting, updating, and stopping the timer Live Activity.
/// Automatically reconnects to existing activities on app launch.
@MainActor
class LiveActivityManager {
    
    // MARK: - Singleton
    
    static let shared = LiveActivityManager()
    
    // MARK: - Properties
    
    /// The currently active Live Activity, if any.
    private var activity: Activity<RetainerActivityAttributes>?
    
    // MARK: - Initialization
    
    private init() {
        // Reconnect to any existing activity from a previous session.
        if let existingActivity = Activity<RetainerActivityAttributes>.activities.first {
            self.activity = existingActivity
        }
    }
    
    // MARK: - Public Methods
    
    /// Starts a new Live Activity with the current timer state.
    /// - Parameters:
    ///   - accumulatedTime: Total time accumulated before this session.
    ///   - goal: The user's goal threshold in seconds.
    ///   - danger: The user's danger threshold in seconds.
    func start(accumulatedTime: Double, goal: Double, danger: Double) {
        let effectiveStartDate = Date().addingTimeInterval(-accumulatedTime)
        
        let attributes = RetainerActivityAttributes(name: "Retainer Timer")
        let contentState = RetainerActivityAttributes.ContentState(
            effectiveStartDate: effectiveStartDate,
            isRunning: true,
            accumulatedTime: accumulatedTime,
            goal: goal,
            danger: danger
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            self.activity = activity
        } catch {
            // Activity request failed (e.g., user disabled Live Activities)
        }
    }
    
    /// Updates the Live Activity with new timer state.
    /// - Parameters:
    ///   - isRunning: Whether the timer is currently running.
    ///   - accumulatedTime: Current accumulated time in seconds.
    ///   - goal: The user's goal threshold in seconds.
    ///   - danger: The user's danger threshold in seconds.
    func update(isRunning: Bool, accumulatedTime: Double, goal: Double, danger: Double) {
        guard let activity = activity else { return }
        
        let effectiveStartDate = isRunning ? Date().addingTimeInterval(-accumulatedTime) : Date()
        
        let contentState = RetainerActivityAttributes.ContentState(
            effectiveStartDate: effectiveStartDate,
            isRunning: isRunning,
            accumulatedTime: accumulatedTime,
            goal: goal,
            danger: danger
        )
        
        Task {
            await activity.update(
                ActivityContent(state: contentState, staleDate: nil)
            )
        }
    }
    
    /// Ends the Live Activity immediately.
    func stop() {
        guard let activity = activity else { return }
        
        let finalContentState = RetainerActivityAttributes.ContentState(
            effectiveStartDate: Date(),
            isRunning: false,
            accumulatedTime: 0,
            goal: 0,
            danger: 0
        )
        
        Task {
            await activity.end(
                ActivityContent(state: finalContentState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            self.activity = nil
        }
    }
}
