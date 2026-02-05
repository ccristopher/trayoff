//
//  OnboardingView.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import SwiftUI

/// First-launch onboarding experience introducing app features.
///
/// Presents a paginated walkthrough explaining timer tracking,
/// goals, and reminders before allowing the user to start using the app.
struct OnboardingView: View {
    
    // MARK: - Properties
    
    /// Binding to track whether onboarding has been completed.
    @Binding var hasSeenOnboarding: Bool
    
    @State private var currentPage = 0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage(
                    imageName: "timer",
                    title: "Track Your Progress",
                    description: "Keep track of how long you wear your retainers each day."
                )
                .tag(0)
                
                OnboardingPage(
                    imageName: "chart.bar.fill",
                    title: "Hit Your Daily Goal",
                    description: "Visualize your consistency and build a streak."
                )
                .tag(1)
                
                OnboardingPage(
                    imageName: "bell.badge",
                    title: "Set Reminders",
                    description: "Hold the timer button to set a reminder so you don't forget."
                )
                .tag(2)
                
                // Final page with start button
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)
                        .padding(.bottom, 20)
                    
                    Text("Ready to go?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Start tracking your retainer usage now.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    } label: {
                        Text("Start Tracking")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
                .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - OnboardingPage

/// A single page in the onboarding flow.
struct OnboardingPage: View {
    
    /// SF Symbol name for the page icon.
    let imageName: String
    
    /// Main title text.
    let title: String
    
    /// Description text explaining the feature.
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
