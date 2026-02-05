//
//  ContentView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import SwiftData

/// The root view containing the tab-based navigation structure.
///
/// Manages the main tab bar with Home and Stats tabs, handles first-launch
/// onboarding presentation, and requests notification permissions on startup.
struct ContentView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var viewModel: TimerViewModel
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(1)
        }
        .transition(.identity)
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenOnboarding },
            set: { _ in }
        )) {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
        .task {
            _ = await NotificationService.shared.requestPermissions()
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Session.self, configurations: config)
    let vm = TimerViewModel(modelContext: container.mainContext)
    
    ContentView()
        .environmentObject(vm)
        .modelContainer(container)
}