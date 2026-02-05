//
//  TimeFormatter.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation

/// Utility for formatting time intervals into human-readable strings.
///
/// Provides various formatting options for displaying elapsed time
/// in the timer and statistics views.
enum TimeFormatter {
    
    /// Formats seconds as HH:MM:SS or MM:SS.
    /// - Parameter totalSeconds: The time interval in seconds.
    /// - Returns: Formatted string (e.g., "01:30:45" or "30:45").
    static func format(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        }
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    /// Formats seconds as HH:MM (if hours > 0) or MM:SS.
    /// Omits seconds when displaying hours for cleaner UI.
    /// - Parameter totalSeconds: The time interval in seconds.
    /// - Returns: Simplified formatted string (e.g., "01:30" or "30:45").
    static func formatSimplified(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        
        if hours > 0 {
            return String(format: "%02i:%02i", hours, minutes)
        }
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    /// Returns a human-readable description of the time.
    /// - Parameter totalSeconds: The time interval in seconds.
    /// - Returns: Description string (e.g., "1 hour 30 minutes" or "30 minutes").
    static func formatDescription(_ totalSeconds: Double) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        
        if hours > 0 {
            let hourText = hours == 1 ? "hour" : "hours"
            let minuteText = minutes == 1 ? "minute" : "minutes"
            return "\(hours) \(hourText) \(minutes) \(minuteText)"
        } else {
            let minuteText = minutes == 1 ? "minute" : "minutes"
            return "\(minutes) \(minuteText)"
        }
    }
}