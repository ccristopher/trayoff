//
//  SessionManager.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Protocol

/// Protocol defining session management operations.
@MainActor
protocol SessionManagerProtocol: ObservableObject {
    /// All recorded sessions.
    var sessions: [Session] { get }

    /// Adds a new session with the given time range.
    /// - Parameters:
    ///   - start: When the retainer was removed.
    ///   - end: When the retainer was put back on.
    func addSession(start: Date, end: Date)
    
    /// Updates an existing session.
    /// - Parameter updatedSession: The session with modified values.
    func updateSession(_ updatedSession: Session)
    
    /// Deletes a session.
    /// - Parameter session: The session to remove.
    func deleteSession(_ session: Session)
    
    /// Removes the most recently added session.
    func undoLastSession()
    
    /// Calculates aggregate statistics for all sessions.
    /// - Returns: A tuple with total time, average session time, and session count.
    func getStatistics() -> (totalTime: Double, averageTime: Double, sessionCount: Int)
}

// MARK: - Implementation

/// Manages session CRUD operations using SwiftData.
///
/// Handles persistence of retainer-off sessions and provides
/// methods for adding, updating, and deleting sessions.
@MainActor
class SessionManager: SessionManagerProtocol {
    
    // MARK: - Properties
    
    @Published private(set) var sessions: [Session] = []
    private let modelContext: ModelContext

    // MARK: - Initialization
    
    /// Creates a session manager with the given SwiftData context.
    /// - Parameter modelContext: The SwiftData model context for persistence.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSessions()
    }

    // MARK: - Public Methods
    
    func addSession(start: Date, end: Date) {
        let session = Session(start: start, end: end)
        modelContext.insert(session)
        saveContext()
        loadSessions()
    }

    func updateSession(_ updatedSession: Session) {
        saveContext()
        loadSessions()
    }

    func deleteSession(_ session: Session) {
        modelContext.delete(session)
        saveContext()
        loadSessions()
    }

    func undoLastSession() {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.start, order: .reverse)])
        if let lastSession = try? modelContext.fetch(descriptor).first {
            modelContext.delete(lastSession)
            saveContext()
            loadSessions()
        }
    }

    /// Removes all sessions from the database.
    func undoAllSessions() {
        try? modelContext.delete(model: Session.self)
        saveContext()
        loadSessions()
    }

    func getStatistics() -> (totalTime: Double, averageTime: Double, sessionCount: Int) {
        let totalTime = sessions.reduce(0.0) { $0 + $1.duration }
        let averageTime = sessions.isEmpty ? 0.0 : totalTime / Double(sessions.count)
        return (totalTime, averageTime, sessions.count)
    }

    // MARK: - Private Methods
    
    private func saveContext() {
        try? modelContext.save()
    }

    private func loadSessions() {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.start)])
        do {
            sessions = try modelContext.fetch(descriptor)
        } catch {
            sessions = []
        }
    }
}
