//
//  TimerViewModel.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import Combine
import SwiftData
import WidgetKit

/// Main ViewModel coordinating timer state, sessions, and UI updates.
///
/// Acts as the central hub connecting the timer engine, session manager,
/// persistence, and reminder functionality. Publishes state changes for
/// SwiftUI views to observe.
@MainActor
class TimerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Whether the timer is currently running.
    @Published private(set) var isRunning: Bool = false
    
    /// Current progress in seconds (accumulated + current session).
    @Published private(set) var currentProgress: Double = 0.0
    
    /// All recorded sessions.
    @Published private(set) var sessions: [Session] = []
    
    /// Seconds remaining until the reminder fires.
    @Published private(set) var reminderCountdown: Int = 0
    
    /// Selected reminder duration in minutes.
    @Published var selectedReminder: Int {
        didSet {
            reminderManager.selectedReminder = selectedReminder
        }
    }

    /// The user's goal threshold in seconds.
    @Published var goal: Double = AppConfig.Timer.defaultGoal
    
    /// The user's danger threshold in seconds.
    @Published var danger: Double = AppConfig.Timer.defaultDanger
    
    /// Whether to show the goal status indicator on the home screen.
    @Published var showGoalStatus: Bool = UserDefaults.standard.bool(forKey: "showGoalStatus") {
        didSet {
            UserDefaults.standard.set(showGoalStatus, forKey: "showGoalStatus")
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns the appropriate color based on current progress vs thresholds.
    var currentColor: Color {
        if currentProgress <= goal {
            return .green
        } else if currentProgress <= danger {
            return .yellow
        } else {
            return .red
        }
    }
    
    /// Sessions from today, sorted newest first.
    var todaySessions: [Session] {
        let today = Self.today()
        return sessionManager.sessions
            .filter { Calendar.current.isDate($0.start, inSameDayAs: today) }
            .sorted { $0.start > $1.start }
    }
    
    /// All sessions from the database.
    var allSessions: [Session] {
        return sessionManager.sessions
    }
    
    // MARK: - Private Properties
    
    private let timerEngine: TimerEngine
    private let sessionManager: SessionManager
    private let reminderManager: ReminderManager
    private let persistenceService: TimerPersistenceServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var currentSessionStart: Date?
    private var lastResetDate: Date
    
    private var modelContext: ModelContext?

    // MARK: - Initialization
    
    /// Creates a new TimerViewModel with the given dependencies.
    /// - Parameters:
    ///   - modelContext: SwiftData context for session persistence.
    ///   - timerEngine: Engine handling timer ticks (injectable for testing).
    ///   - reminderManager: Manager for reminder countdown.
    ///   - persistenceService: Service for saving/loading timer state.
    init(
        modelContext: ModelContext,
        timerEngine: TimerEngine = TimerEngine(),
        reminderManager: ReminderManager = ReminderManager(),
        persistenceService: TimerPersistenceServiceProtocol = TimerPersistenceService()
    ) {
        self.modelContext = modelContext
        self.timerEngine = timerEngine
        self.sessionManager = SessionManager(modelContext: modelContext)
        self.reminderManager = reminderManager
        self.persistenceService = persistenceService
        self.selectedReminder = reminderManager.selectedReminder
        self.lastResetDate = Self.today()

        loadState()
        setupBindings()
        checkForMidnightReset()

        if isRunning {
            timerEngine.resume()
            if let startTime = reminderManager.reminderStartTime {
                reminderManager.resumeReminder(from: startTime)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Toggles the timer between running and stopped states.
    func toggleTimer() {
        timerEngine.toggle()

        if timerEngine.isRunning {
            currentSessionStart = Date()
            reminderManager.startReminder()
            LiveActivityManager.shared.start(
                accumulatedTime: timerEngine.accumulatedTime,
                goal: goal,
                danger: danger
            )
        } else {
            if let start = currentSessionStart {
                sessionManager.addSession(start: start, end: Date())
                currentSessionStart = nil
            }
            reminderManager.stopReminder()
            LiveActivityManager.shared.stop()
        }

        saveState()
    }

    /// Resets the timer to zero and clears current session.
    func resetTimer() {
        timerEngine.reset()
        reminderManager.stopReminder()
        lastResetDate = Self.today()
        currentSessionStart = nil
        LiveActivityManager.shared.stop()
        saveState()
    }
    
    /// Called when the app is about to become inactive.
    func appWillBecomeInactive() {
        timerEngine.pause()
        saveState()
    }
    
    /// Called when the app becomes active.
    func appDidBecomeActive() {
        checkForMidnightReset()
        timerEngine.resume()
        
        if let startTime = reminderManager.reminderStartTime, timerEngine.isRunning {
            reminderManager.resumeReminder(from: startTime)
        }
    }
    
    /// Removes the most recent session and recalculates totals.
    func undoLastSession() {
        sessionManager.undoLastSession()
        recalculateAccumulatedTime()
    }
    
    /// Returns aggregate statistics for today's sessions.
    func getStatistics() -> (totalTime: Double, averageTime: Double, sessionCount: Int) {
        let today = Self.today()
        let todaySessions = sessionManager.sessions.filter { Calendar.current.isDate($0.start, inSameDayAs: today) }
        
        let totalTime = todaySessions.reduce(0.0) { $0 + $1.duration }
        let averageTime = todaySessions.isEmpty ? 0.0 : totalTime / Double(todaySessions.count)
        
        return (totalTime, averageTime, todaySessions.count)
    }
    
    /// Statistics about goal streaks.
    struct StreakStats {
        let currentStreak: Int
        let bestStreak: Int
        let daysMetGoalLast7Days: Int
    }
    
    /// Calculates streak statistics based on daily goal compliance.
    func getStreakStats() -> StreakStats {
        let calendar = Calendar.current
        let today = Self.today()
        
        let groupedSessions = Dictionary(grouping: sessionManager.sessions) { session -> Date in
            calendar.startOfDay(for: session.start)
        }
        
        var dailyDurations: [Date: TimeInterval] = [:]
        for (date, sessions) in groupedSessions {
            let totalDuration = sessions.reduce(0) { $0 + $1.duration }
            dailyDurations[date] = totalDuration
        }
        
        let sortedDates = dailyDurations.keys.sorted()
        let firstDate = sortedDates.first ?? today
        
        func isGoalMet(on date: Date) -> Bool {
            if date < firstDate { return false }
            return (dailyDurations[date] ?? 0) <= goal
        }
        
        // Current Streak
        var currentStreak = 0
        var checkDate = today
        
        if !isGoalMet(on: today) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        }
        
        while isGoalMet(on: checkDate) {
            currentStreak += 1
            guard let prevDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            if prevDate < firstDate { break }
            checkDate = prevDate
        }
        
        // Best Streak
        var bestStreak = 0
        var tempStreak = 0
        
        if !sortedDates.isEmpty {
            let daysCount = calendar.dateComponents([.day], from: firstDate, to: today).day ?? 0
            
            for i in 0...daysCount {
                if let date = calendar.date(byAdding: .day, value: i, to: firstDate) {
                    if isGoalMet(on: date) {
                        tempStreak += 1
                        bestStreak = max(bestStreak, tempStreak)
                    } else {
                        tempStreak = 0
                    }
                }
            }
        } else {
             if isGoalMet(on: today) {
                 bestStreak = 1
             }
        }
        
        // Last 7 Days
        var daysMet7 = 0
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                if isGoalMet(on: date) {
                    daysMet7 += 1
                }
            }
        }
        
        return StreakStats(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            daysMetGoalLast7Days: daysMet7
        )
    }
    
    /// Updates a session and recalculates accumulated time.
    func updateSession(_ updatedSession: Session) {
        sessionManager.updateSession(updatedSession)
        recalculateAccumulatedTime()
    }

    /// Deletes a session and recalculates accumulated time.
    func deleteSession(_ session: Session) {
        sessionManager.deleteSession(session)
        recalculateAccumulatedTime()
    }
    
    /// Deletes all sessions from today.
    func deleteAllTodaySessions() {
        let today = Self.today()
        let sessionsToDelete = sessionManager.sessions.filter { Calendar.current.isDate($0.start, inSameDayAs: today) }
        
        for session in sessionsToDelete {
            sessionManager.deleteSession(session)
        }
        recalculateAccumulatedTime()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        timerEngine.$isRunning
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)

        timerEngine.$currentProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.currentProgress = self?.timerEngine.currentProgress ?? 0.0
                self?.checkForMidnightReset()
            }
            .store(in: &cancellables)

        sessionManager.$sessions
            .assign(to: \.sessions, on: self)
            .store(in: &cancellables)

        reminderManager.$reminderCountdown
            .assign(to: \.reminderCountdown, on: self)
            .store(in: &cancellables)
    }
    
    private func recalculateAccumulatedTime() {
        let today = Self.today()
        let todaySessions = sessionManager.sessions.filter { Calendar.current.isDate($0.start, inSameDayAs: today) }
        
        let totalDuration = todaySessions.reduce(0.0) { $0 + $1.duration }
        timerEngine.setAccumulatedTime(totalDuration)
        saveState()
    }

    // MARK: - Persistence
    
    private func loadState() {
        guard let state = persistenceService.loadTimerState() else { return }

        timerEngine.setInitialState(
            startTime: state.startTime,
            isRunning: state.isRunning,
            accumulatedTime: state.accumulatedTime
        )

        reminderManager.setInitialState(
            reminderStartTime: state.reminderStartTime
        )

        self.lastResetDate = state.lastResetDate
        self.currentSessionStart = state.currentSessionStart
    }
    
    private func saveState() {
        let state = TimerState(
            startTime: timerEngine.timerStartTime.timeIntervalSinceReferenceDate,
            isRunning: timerEngine.isRunning,
            accumulatedTime: timerEngine.accumulatedTime,
            lastResetDate: lastResetDate,
            reminderStartTime: reminderManager.reminderStartTime,
            currentSessionStart: currentSessionStart,
            goal: goal,
            danger: danger
        )
        persistenceService.saveTimerState(state)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Helpers
    
    private static func today() -> Date {
        let now = Date()
        let calendar = Calendar.current
        return calendar.startOfDay(for: now)
    }
    
    private func checkForMidnightReset() {
        let today = Self.today()
        if lastResetDate != today {
            handleMidnightCrossing(today: today)
            lastResetDate = today
            saveState()
        }
    }
    
    private func handleMidnightCrossing(today: Date) {
        if isRunning, let start = currentSessionStart {
            let midnight = today
            
            if start < midnight {
                sessionManager.addSession(start: start, end: midnight)
                currentSessionStart = midnight
                
                let yesterdayDuration = midnight.timeIntervalSince(start)
                
                timerEngine.stop()
                let newTotal = max(0, timerEngine.accumulatedTime - yesterdayDuration)
                
                timerEngine.reset()
                timerEngine.setAccumulatedTime(newTotal)
                timerEngine.start()
            }
        } else {
            recalculateAccumulatedTime()
        }
    }
}
