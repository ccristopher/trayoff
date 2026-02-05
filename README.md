# TrayOff

[![iOS 16.0+](https://img.shields.io/badge/iOS-16.0%2B-blue)](https://developer.apple.com/ios/)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern SwiftUI app to track retainer usage time with a beautiful UI and helpful statistics.

## Features

- **Timer Tracking** — Track how long your retainer has been off
- **Visual Feedback** — Color-coded ring shows progress toward goals
- **Statistics** — View daily session history, streaks, and goal compliance
- **Live Activities** — See timer status on your Lock Screen and Dynamic Island
- **Customizable Goals** — Set your own time goals and danger thresholds
- **Reminders** — Get notified when it's time to put your retainer back on
- **Modern UI** — Beautiful interface with animations and iOS 26 glass effects

## Screenshots

*Coming soon*

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
   ```bash
   git clone https://github.com/YOUR_USERNAME/TrayOff.git
   ```
2. Open `TrayOff.xcodeproj` in Xcode
3. Build and run on your device or simulator

## Architecture

The app follows the **MVVM** (Model-View-ViewModel) architecture:

| Layer | Purpose |
|-------|---------|
| **Models** | Data structures (`Session`) |
| **Views** | SwiftUI UI components |
| **ViewModels** | Business logic connecting models and views |
| **Services** | Persistence, notifications, timer engine |
| **Utils** | Configuration and formatting utilities |

## Project Structure

```
TrayOff/
├── Retainer Tracker/
│   ├── App/
│   │   └── TrayOff.swift              # App entry point
│   ├── Models/
│   │   ├── Session.swift              # Session data model
│   │   └── RetainerActivityAttributes.swift
│   ├── Views/
│   │   ├── ContentView.swift          # Tab-based root view
│   │   ├── HomeView.swift             # Main timer interface
│   │   ├── StatsView.swift            # Statistics and history
│   │   ├── SettingsView.swift         # User preferences
│   │   ├── OnboardingView.swift       # First-launch experience
│   │   └── Components/
│   │       ├── ActivityRing.swift
│   │       ├── BackgroundGradientView.swift
│   │       ├── GoalStatusView.swift
│   │       ├── StatusView.swift
│   │       ├── TimerButtonView.swift
│   │       └── TimerRingView.swift
│   ├── ViewModels/
│   │   └── TimerViewModel.swift       # Core timer logic
│   ├── Services/
│   │   ├── NotificationService.swift  # Local notifications
│   │   ├── PersistenceService.swift   # Timer state persistence
│   │   ├── SessionManager.swift       # Session CRUD operations
│   │   ├── TimerEngine.swift          # Timer tick handling
│   │   ├── ReminderManager.swift      # Reminder countdown
│   │   └── LiveActivityManager.swift  # Live Activity support
│   └── Utils/
│       ├── AppConfig.swift            # App constants
│       └── TimeFormatter.swift        # Duration formatting
├── RetainerWidget/
│   ├── RetainerWidget.swift           # Home screen widget
│   ├── RetainerActivityWidget.swift   # Live Activity UI
│   └── RetainerWidgetBundle.swift     # Widget bundle
└── TrayOff.xcodeproj
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Author

**Cristopher Encarnacion**