//
//  SessionDayAllocator.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation

/// Allocates session durations across calendar days without changing stored sessions.
enum SessionDayAllocator {
    
    /// Splits a time interval into duration buckets keyed by calendar day.
    /// - Parameters:
    ///   - start: The interval start.
    ///   - end: The interval end.
    ///   - calendar: Calendar used for day boundaries.
    /// - Returns: Duration in seconds per day.
    static func durationByDay(
        start: Date,
        end: Date,
        calendar: Calendar = .current
    ) -> [Date: TimeInterval] {
        guard end > start else { return [:] }
        
        var durations: [Date: TimeInterval] = [:]
        var cursor = start
        
        while cursor < end {
            let dayStart = calendar.startOfDay(for: cursor)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                break
            }
            
            let segmentEnd = min(end, nextDay)
            durations[dayStart, default: 0] += segmentEnd.timeIntervalSince(cursor)
            cursor = segmentEnd
        }
        
        return durations
    }
    
    /// Calculates total session duration overlapping a single calendar day.
    /// - Parameters:
    ///   - day: Any date inside the target day.
    ///   - sessions: Sessions to inspect.
    ///   - calendar: Calendar used for day boundaries.
    /// - Returns: Duration in seconds for the target day.
    static func duration(
        on day: Date,
        sessions: [Session],
        calendar: Calendar = .current
    ) -> TimeInterval {
        let dayStart = calendar.startOfDay(for: day)
        
        return sessions.reduce(0) { total, session in
            total + (durationByDay(start: session.start, end: session.end, calendar: calendar)[dayStart] ?? 0)
        }
    }
    
    /// Calculates total session duration for each requested calendar day.
    /// - Parameters:
    ///   - days: Dates representing target days.
    ///   - sessions: Sessions to inspect.
    ///   - calendar: Calendar used for day boundaries.
    /// - Returns: Duration in seconds keyed by each requested day start.
    static func durationsByDay(
        for days: [Date],
        sessions: [Session],
        calendar: Calendar = .current
    ) -> [Date: TimeInterval] {
        var durations = Dictionary(
            uniqueKeysWithValues: days.map { (calendar.startOfDay(for: $0), TimeInterval(0)) }
        )
        
        for session in sessions {
            let sessionDurations = durationByDay(start: session.start, end: session.end, calendar: calendar)
            for day in durations.keys {
                if let duration = sessionDurations[day] {
                    durations[day, default: 0] += duration
                }
            }
        }
        
        return durations
    }
    
    /// Returns sessions that overlap the given calendar day.
    /// - Parameters:
    ///   - day: Any date inside the target day.
    ///   - sessions: Sessions to inspect.
    ///   - calendar: Calendar used for day boundaries.
    /// - Returns: Sessions with any duration inside the target day.
    static func sessionsOverlapping(
        day: Date,
        sessions: [Session],
        calendar: Calendar = .current
    ) -> [Session] {
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return []
        }
        
        return sessions.filter { session in
            session.start < dayEnd && session.end > dayStart
        }
    }
}
