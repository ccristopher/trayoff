//
//  SettingsView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import SwiftData

/// View for configuring app settings.
///
/// Allows users to customize their goal and danger thresholds,
/// set a default reminder duration, and toggle goal status visibility.
struct SettingsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Timer Goals")) {
                    VStack(alignment: .leading) {
                        Text("Goal: \(TimeFormatter.formatDescription(viewModel.goal))")
                            .font(.headline)
                        Slider(
                            value: $viewModel.goal,
                            in: 60...7200,
                            step: 60
                        )
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Danger: \(TimeFormatter.formatDescription(viewModel.danger))")
                            .font(.headline)
                        Slider(
                            value: $viewModel.danger,
                            in: viewModel.goal...14400,
                            step: 60
                        )
                    }
                    
                    Toggle("Show Goal Status", isOn: $viewModel.showGoalStatus)
                }
                
                Section(header: Text("Default Reminder")) {
                    Picker("Default Reminder", selection: $viewModel.selectedReminder) {
                        ForEach(AppConfig.Timer.reminderOptions, id: \.self) { minutes in
                            Text("\(minutes) minutes").tag(minutes)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
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
    SettingsView(viewModel: vm)
        .modelContainer(container)
}
