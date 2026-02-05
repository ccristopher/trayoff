//
//  RetainerActivityAttributes.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation
import ActivityKit

/// Attributes for the retainer timer Live Activity.
///
/// Used to display timer information on the Lock Screen and Dynamic Island.
struct RetainerActivityAttributes: ActivityAttributes {
    /// Dynamic state that updates while the Live Activity is running.
    public struct ContentState: Codable, Hashable {
        /// The effective start time, accounting for accumulated time.
        var effectiveStartDate: Date
        
        /// Whether the timer is currently running.
        var isRunning: Bool
        
        /// Total accumulated time in seconds before this session.
        var accumulatedTime: Double
        
        /// The user's goal threshold in seconds.
        var goal: Double
        
        /// The user's danger threshold in seconds.
        var danger: Double
    }
    
    /// Display name for the activity.
    var name: String
}
