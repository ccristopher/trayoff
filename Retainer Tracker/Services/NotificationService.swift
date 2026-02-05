//
//  NotificationService.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import UserNotifications
import SwiftUI

/// Service for managing local notifications.
///
/// Handles requesting permissions and scheduling reminder notifications
/// to alert the user when it's time to put their retainer back on.
class NotificationService {
    
    // MARK: - Singleton
    
    static let shared = NotificationService()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Requests notification permissions from the user.
    /// - Returns: Whether permission was granted.
    func requestPermissions() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            return false
        }
    }
    
    /// Schedules a reminder notification after the specified duration.
    /// - Parameter minutes: Number of minutes until the notification fires.
    /// - Note: Cancels any existing reminder before scheduling the new one.
    func scheduleReminder(minutes: Int) {
        // Remove any existing notifications
        cancelReminder()
        
        // Don't schedule if minutes is 0
        guard minutes > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Retainer Reminder"
        content.body = "Time to put your retainer back on!"
        content.sound = .default
        
        // Create trigger for the specified number of minutes
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "retainerReminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationService] Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Cancels any pending reminder notifications.
    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["retainerReminder"]
        )
    }
}
