//
//  TrayOff.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI
import SwiftData

/// The main app struct that configures the environment and scene hierarchy.
///
/// Initializes the SwiftData container and TimerViewModel, and responds
/// to scene phase changes to manage timer state persistence.
@available(iOS 26.0, *)
@main
struct TrayOffApp: App {
    
    // MARK: - Properties
    
    @Environment(\.scenePhase) private var scenePhase
    
    /// The SwiftData model container for session persistence.
    let container: ModelContainer
    
    /// The main ViewModel managing timer state.
    @StateObject private var viewModel: TimerViewModel
    
    // MARK: - Initialization
    
    init() {
        do {
            let schema = Schema([Session.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            let context = container.mainContext
            let vm = TimerViewModel(modelContext: context)
            _viewModel = StateObject(wrappedValue: vm)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.appDidBecomeActive()
            case .inactive:
                viewModel.appWillBecomeInactive()
            case .background:
                viewModel.appWillBecomeInactive()
            @unknown default:
                break
            }
        }
    }
}
