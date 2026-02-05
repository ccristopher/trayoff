//
//  StatsView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import Charts
import SwiftData

/// View displaying timer statistics, session history, and streak information.
///
/// Shows an overview with current streak, best streak, and last 7 days progress,
/// a bar chart of the past week's usage, and a list of today's sessions.
struct StatsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: TimerViewModel
    @State private var selectedSession: Session? = nil
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    StatsSummaryView(viewModel: viewModel)
                }
                
                Section {
                    HistoryView(viewModel: viewModel)
                }
                
                Section {
                    if viewModel.todaySessions.isEmpty {
                        Text("No sessions recorded today")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.todaySessions) { session in
                            Button(action: {
                                if !isEditing {
                                    selectedSession = session
                                }
                            }) {
                                SessionItemView(session: session)
                            }
                            .foregroundStyle(.primary)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteSession(session)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let session = viewModel.todaySessions[index]
                                viewModel.deleteSession(session)
                            }
                        }
                    }
                } header: {
                    Text("Today's Sessions")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                        .padding(.top, 8)
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isEditing {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Text("Delete All")
                        }
                        .popover(isPresented: $showDeleteConfirmation) {
                            VStack(spacing: 16) {
                                Text("Are you sure?")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 200)
                                
                                Button("Delete All", role: .destructive) {
                                    withAnimation {
                                        viewModel.deleteAllTodaySessions()
                                        isEditing = false
                                        showDeleteConfirmation = false
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        if isEditing {
                            Image(systemName: "checkmark")
                                .fontWeight(.bold)
                        } else {
                            Text("Edit")
                                .fontWeight(.regular)
                        }
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                EditSessionView(
                    session: session,
                    onSave: { updatedSession in
                        viewModel.updateSession(updatedSession)
                        selectedSession = nil
                    },
                    onDelete: {
                        viewModel.deleteSession(session)
                        selectedSession = nil
                    },
                    onCancel: {
                        selectedSession = nil
                    }
                )
            }
        }
    }
}

// MARK: - StatsSummaryView

/// Displays streak and goal compliance overview.
struct StatsSummaryView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        let stats = viewModel.getStreakStats()
        
        VStack(alignment: .leading, spacing: AppConfig.UI.defaultSpacing) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: AppConfig.UI.defaultSpacing * 2) {
                StatItemView(
                    title: "Current Streak",
                    value: "\(stats.currentStreak) days",
                    icon: "flame.fill",
                    iconColor: .orange
                )
                
                StatItemView(
                    title: "Best Streak",
                    value: "\(stats.bestStreak) days",
                    icon: "trophy.fill",
                    iconColor: .yellow
                )
                
                StatItemView(
                    title: "Last 7 Days",
                    value: "\(stats.daysMetGoalLast7Days)/7",
                    icon: "calendar.badge.checkmark",
                    iconColor: .green
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - StatItemView

/// Displays a single statistic with icon, title, and value.
struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    var iconColor: Color = .blue
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .padding(10)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )
                .padding(.bottom, 4)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SessionItemView

/// Displays a single session with start/end times and duration.
struct SessionItemView: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(session.start.formatted(date: .omitted, time: .shortened))
                        .font(.headline)
                    Text("to")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.end.formatted(date: .omitted, time: .shortened))
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(TimeFormatter.format(session.duration))
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - HistoryView

/// Bar chart showing daily usage for the past 7 days.
struct HistoryView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConfig.UI.defaultSpacing) {
            Text("History (Last 7 Days)")
                .font(.title2)
                .fontWeight(.bold)
            
            let data = getHistoryData()
            
            if data.isEmpty {
                 Text("No history available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Duration", item.duration / 3600)
                    )
                    .foregroundStyle(barColor(for: item.duration))
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let doubleValue = value.as(Double.self),
                           doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel("\(Int(doubleValue))h")
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        if value.as(Date.self) != nil {
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func barColor(for duration: TimeInterval) -> Color {
        if duration <= viewModel.goal {
            return .green
        } else if duration <= viewModel.danger {
            return .yellow
        } else {
            return .red
        }
    }
    
    /// Data point for daily chart.
    struct DailyData: Identifiable {
        var id: Date { date }
        let date: Date
        let duration: TimeInterval
    }
    
    private func getHistoryData() -> [DailyData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var days: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                days.append(date)
            }
        }
        days.reverse()
        
        let groupedSessions = Dictionary(grouping: viewModel.allSessions) { session -> Date in
            calendar.startOfDay(for: session.start)
        }
        
        return days.map { date in
            let sessions = groupedSessions[date] ?? []
            let totalDuration = sessions.reduce(0) { $0 + $1.duration }
            return DailyData(date: date, duration: totalDuration)
        }
    }
}

// MARK: - EditSessionView

/// Sheet for editing a session's start and end times.
struct EditSessionView: View {
    let session: Session
    var onSave: (Session) -> Void
    var onDelete: () -> Void
    var onCancel: () -> Void
    
    @State private var startDate: Date
    @State private var endDate: Date
    
    init(session: Session, onSave: @escaping (Session) -> Void, onDelete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.session = session
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        _startDate = State(initialValue: session.start)
        _endDate = State(initialValue: session.end)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Start Time")) {
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("End Time")) {
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        session.start = startDate
                        session.end = endDate
                        onSave(session)
                    }
                    .disabled(endDate < startDate)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, configurations: config)
    let vm = TimerViewModel(modelContext: container.mainContext)
    StatsView(viewModel: vm)
        .modelContainer(container)
}
