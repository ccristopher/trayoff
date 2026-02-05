//
//  Session.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation
import SwiftData

/// A recorded session representing a period when the retainer was off.
///
/// Sessions are persisted using SwiftData and used to calculate daily usage
/// statistics, streaks, and goal compliance.
@Model
final class Session {
    /// Unique identifier for the session.
    var id: UUID
    
    /// When the retainer was removed.
    var start: Date
    
    /// When the retainer was put back on.
    var end: Date
    
    /// The total duration of this session in seconds.
    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }
    
    /// Creates a new session with the given time range.
    /// - Parameters:
    ///   - start: When the retainer was removed.
    ///   - end: When the retainer was put back on.
    init(start: Date, end: Date) {
        self.id = UUID()
        self.start = start
        self.end = end
    }
}
