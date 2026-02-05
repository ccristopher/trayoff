//
//  TimerButtonView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import SwiftData

// MARK: - Glass Effect Extension

/// Adds iOS 26+ glass effect if available, otherwise returns the original view.
extension View {
    /// Conditionally applies glassEffect() on supported OS versions.
    @ViewBuilder
    func glassIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive())
        } else {
            self
        }
    }
}

// MARK: - TimerButtonView

/// Circular button for toggling the timer state.
///
/// Supports a long-press gesture to show a reminder duration picker.
/// Displays the remaining reminder countdown when active.
struct TimerButtonView: View {
    
    // MARK: - Properties
    
    /// Whether the timer is currently running.
    let isRunning: Bool
    
    /// Action to perform when the button is tapped.
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    /// The currently selected reminder duration in minutes.
    @Binding var selectedReminder: Int
    
    /// Whether the time picker is showing.
    @Binding var showTimePicker: Bool
    
    /// Called when a reminder duration is selected.
    let onSelectReminder: (Int) -> Void
    
    @ObservedObject var viewModel: TimerViewModel

    /// Available reminder durations in minutes.
    let reminderTimes = [0, 1, 20, 30, 60]

    // MARK: - Computed Properties
    
    var backgroundColor: Color {
        if isRunning {
            return colorScheme == .dark ? .white : .black
        } else {
            return Color(.systemGray5)
        }
    }

    var labelColor: Color {
        if isRunning {
            return colorScheme == .dark ? .black : .white
        } else {
            return colorScheme == .dark ? .white : .black
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Main button
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .glassIfAvailable()
                        .frame(width: 225, height: 225)
                    Text(isRunning ? "Retainer Off" : "Retainer On")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(labelColor)
                        .accessibilityLabel(isRunning ? "Turn retainer off" : "Turn retainer on")
                }
                .sensoryFeedback(
                    .impact(weight: .heavy, intensity: 0.75),
                    trigger: isRunning
                )
                .sensoryFeedback(
                    isRunning ? .warning : .success,
                    trigger: isRunning
                )
                .scaleEffect(isRunning ? 0.975 : 1.0)
                .animation(.easeOut(duration: AppConfig.Animation.standard), value: isRunning)
            }
            .highPriorityGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        if !isRunning {
                            withAnimation(.easeInOut) {
                                showTimePicker = true
                            }
                        }
                    }
            )
            .sensoryFeedback(.impact(weight: .medium), trigger: showTimePicker)
            
            // Wheel picker overlay on long press
            if showTimePicker {
                Picker("", selection: $selectedReminder) {
                    ForEach(reminderTimes, id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 225, height: 225)
                .background(backgroundColor)
                .clipShape(Circle())
                .zIndex(10)
            }
        }
        .overlay(alignment: .bottom) {
            // Countdown or Select button
            Group {
                if isRunning && viewModel.reminderCountdown > 0 {
                    Text(formatCountdown(viewModel.reminderCountdown))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(labelColor)
                        .frame(width: 120, height: 40)
                        .background(backgroundColor)
                        .clipShape(Capsule())
                        .glassIfAvailable()
                        .shadow(color: backgroundColor.opacity(0.2), radius: 1.0)
                        .offset(y: 90)
                        .zIndex(10)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                } else if showTimePicker {
                    Button("Select") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showTimePicker = false
                        }
                        onSelectReminder(selectedReminder)
                        action()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(labelColor)
                    .frame(width: 120, height: 40)
                    .background(backgroundColor)
                    .clipShape(Capsule())
                    .glassIfAvailable()
                    .shadow(color: backgroundColor.opacity(0.2), radius: 1.0)
                    .offset(y: 90)
                    .zIndex(10)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isRunning)
            .animation(.easeInOut(duration: 0.3), value: showTimePicker)
        }
    }
    
    // MARK: - Private Methods
    
    private func formatCountdown(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, configurations: config)
    let vm = TimerViewModel(modelContext: container.mainContext)
    
    TimerButtonView(
        isRunning: false,
        action: {},
        selectedReminder: .constant(10),
        showTimePicker: .constant(false),
        onSelectReminder: { _ in },
        viewModel: vm
    )
    .modelContainer(container)
}
