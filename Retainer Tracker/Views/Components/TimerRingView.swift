//
//  TimerRingView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import SwiftData

/// Combines the activity ring and timer button into a single component.
///
/// This is the main interactive element on the home screen, containing
/// the progress ring and the central button for starting/stopping the timer.
struct TimerRingView: View {
    
    // MARK: - Properties
    
    /// Current progress in seconds.
    let progress: Double
    
    /// Goal threshold in seconds.
    let goal: Double
    
    /// Danger threshold in seconds.
    let danger: Double
    
    /// Whether the timer is currently running.
    let isRunning: Bool
    
    /// Action to perform when the button is tapped.
    let onButtonTap: () -> Void
    
    /// The color to display on the ring.
    let ringColor: Color
    
    /// The currently selected reminder duration in minutes.
    @Binding var selectedReminder: Int
    
    /// Whether the time picker is showing.
    @Binding var showTimePicker: Bool
    
    /// Called when a reminder duration is selected.
    let onSelectReminder: (Int) -> Void
    
    @ObservedObject var viewModel: TimerViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            ActivityRing(
                progress: progress,
                goal: goal,
                danger: danger,
                ringColor: ringColor
            )
            .animation(.easeOut(duration: AppConfig.Animation.fast), value: progress)
            .frame(width: AppConfig.UI.ringSize, height: AppConfig.UI.ringSize)
            
            TimerButtonView(
                isRunning: isRunning,
                action: onButtonTap,
                selectedReminder: $selectedReminder,
                showTimePicker: $showTimePicker,
                onSelectReminder: onSelectReminder,
                viewModel: viewModel
            )
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, configurations: config)
    let vm = TimerViewModel(modelContext: container.mainContext)
    
    TimerRingView(
        progress: 3600,
        goal: 7200,
        danger: 14400,
        isRunning: false,
        onButtonTap: {},
        ringColor: .blue,
        selectedReminder: .constant(10),
        showTimePicker: .constant(false),
        onSelectReminder: { _ in },
        viewModel: vm
    )
    .modelContainer(container)
}