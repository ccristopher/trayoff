//
//  HomeView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import SwiftData

/// The main screen showing timer status, progress ring, and toggle button.
///
/// Displays the current timer progress with a visual ring, the main toggle
/// button for starting/stopping sessions, and quick access to settings
/// and undo functionality.
struct HomeView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: TimerViewModel
    @State private var showSettingsSheet = false
    @State private var showTimePicker = false
    @Namespace private var liquidNamespace
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradientView(isRunning: viewModel.isRunning, baseColor: viewModel.currentColor)
                
                VStack(spacing: AppConfig.UI.defaultSpacing) {
                    StatusView(progress: viewModel.currentProgress, isRunning: viewModel.isRunning)
                    
                    TimerRingView(
                        progress: viewModel.currentProgress,
                        goal: viewModel.goal,
                        danger: viewModel.danger,
                        isRunning: viewModel.isRunning,
                        onButtonTap: { viewModel.toggleTimer() },
                        ringColor: viewModel.currentColor,
                        selectedReminder: $viewModel.selectedReminder,
                        showTimePicker: $showTimePicker,
                        onSelectReminder: { minutes in
                            viewModel.selectedReminder = minutes
                            showTimePicker = false
                        },
                        viewModel: viewModel
                    )
                }
                .padding()
                .onAppear { viewModel.appDidBecomeActive() }
            }
            .overlay(alignment: .topLeading) {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .padding(.top, 5)
            }
            .overlay(alignment: .top) {
                if viewModel.showGoalStatus {
                    GoalStatusView(
                        progress: viewModel.currentProgress,
                        goal: viewModel.goal,
                        danger: viewModel.danger
                    )
                    .padding(.top, 5)
                }
            }
            .overlay(alignment: .topTrailing) {
                topButtons
                    .padding(.top, 0)
                    .padding(.trailing)
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var topButtons: some View {
        GlassEffectContainer(spacing: AppConfig.UI.defaultSpacing) {
            HStack(spacing: AppConfig.UI.defaultSpacing) {
                if !viewModel.isRunning {
                    Button(role: .destructive) {
                        viewModel.undoLastSession()
                    } label: {
                        Image(systemName: "arrow.uturn.left")
                        .frame(width: AppConfig.UI.buttonIconSize, height: 35.0)
                        .font(.system(size: AppConfig.UI.buttonIconSize))
                        .glassEffectID("undoButton", in: liquidNamespace)
                    }
                    .disabled(viewModel.sessions.isEmpty)
                    .buttonStyle(.glass)
                }
                
                Button {
                    showSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape")
                        .frame(width: AppConfig.UI.buttonIconSize, height: 35.0)
                        .font(.system(size: AppConfig.UI.buttonIconSize))
                        .glassEffectID("settingsButton", in: liquidNamespace)
                }
            }
            .padding(0)
            .buttonStyle(.glass)
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, configurations: config)
    let vm = TimerViewModel(modelContext: container.mainContext)
    HomeView(viewModel: vm)
        .modelContainer(container)
}
