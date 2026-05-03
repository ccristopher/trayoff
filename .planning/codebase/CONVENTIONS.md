---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: quality
---
# Coding Conventions

**Analysis Date:** 2026-05-02

## Naming Patterns

**Files:**
- Use `PascalCase.swift` and match the primary type name: `Retainer Tracker/ViewModels/TimerViewModel.swift`, `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Views/HomeView.swift`.
- Place SwiftUI component files under `Retainer Tracker/Views/Components/` and name them after the component type: `Retainer Tracker/Views/Components/ActivityRing.swift`, `Retainer Tracker/Views/Components/TimerButtonView.swift`.
- Widget files live under `RetainerWidget/` and use widget-specific type names: `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerActivityWidget.swift`, `RetainerWidget/RetainerWidgetBundle.swift`.
- Keep related small helper views in the same feature file when they are private to one screen workflow, as in `Retainer Tracker/Views/StatsView.swift` with `StatsSummaryView`, `StatItemView`, `SessionItemView`, `HistoryView`, and `EditSessionView`.

**Functions:**
- Use lower camel case and verb-first names for actions: `toggleTimer()`, `resetTimer()`, `undoLastSession()`, `deleteAllTodaySessions()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use query-style names for computed data: `getStatistics()`, `getStreakStats()`, `getHistoryData()` in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Use callback labels beginning with `on` for view actions: `onButtonTap`, `onSelectReminder`, `onSave`, `onDelete`, `onCancel` in `Retainer Tracker/Views/Components/TimerRingView.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Keep private helpers under a `// MARK: - Private Methods` section: `formatCountdown(_:)` in `Retainer Tracker/Views/Components/TimerButtonView.swift`, `saveState()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.

**Variables:**
- Use lower camel case for stored and local values: `currentProgress`, `selectedReminder`, `showGoalStatus`, `currentSessionStart`, `lastResetDate` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use boolean prefixes that read naturally: `isRunning`, `isEditing`, `showTimePicker`, `showDeleteConfirmation`, `hasSeenOnboarding` in `Retainer Tracker/Views/StatsView.swift`, `Retainer Tracker/Views/HomeView.swift`, and `Retainer Tracker/Views/ContentView.swift`.
- Use `private(set)` for observable state that views may read but external callers should not mutate: `@Published private(set) var isRunning`, `currentProgress`, and `sessions` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Store shared constants as `static let` inside nested namespace enums rather than free globals: `AppConfig.Timer.defaultGoal`, `AppConfig.UI.ringSize`, `AppConfig.Animation.standard` in `Retainer Tracker/Utils/AppConfig.swift`.

**Types:**
- Use UpperCamelCase for structs, classes, enums, and protocols: `Session`, `TimerEngine`, `TimerEngineProtocol`, `TimerPersistenceServiceProtocol`, `WidgetStatus`.
- Suffix protocols with `Protocol` when they describe a service dependency: `SessionManagerProtocol`, `TimerEngineProtocol`, `ReminderManagerProtocol`, `TimerPersistenceServiceProtocol` in `Retainer Tracker/Services/`.
- Suffix state coordinators with `ViewModel`: `TimerViewModel` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Suffix platform service wrappers with `Manager` or `Service`: `SessionManager`, `ReminderManager`, `LiveActivityManager`, `NotificationService`, `TimerPersistenceService` in `Retainer Tracker/Services/`.
- Use nested enums for local phases or categories: `RingPhase` in `Retainer Tracker/Views/Components/ActivityRing.swift`, `AppConfig.Timer` in `Retainer Tracker/Utils/AppConfig.swift`.

## Code Style

**Formatting:**
- Formatter config: Not detected. No `.swift-format`, `.swiftformat`, `.swiftlint.yml`, or `.editorconfig` files are present.
- Use Xcode-style Swift formatting: 4-space indentation, opening braces on the declaration line, blank lines between logical sections, and trailing multiline argument lists for complex SwiftUI initializers.
- Keep the standard file header at the top of Swift files, matching `Retainer Tracker/App/TrayOff.swift` and the guidance in `CONTRIBUTING.md`:

```swift
//
//  FileName.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//
```

- Organize longer files with `// MARK: - ...` headings. Common section names are `Properties`, `Published Properties`, `Computed Properties`, `Initialization`, `Body`, `Public Methods`, `Private Methods`, `Persistence`, `Helpers`, and `Preview`.
- Keep SwiftUI modifier chains vertically aligned and one modifier per line, as in `Retainer Tracker/Views/HomeView.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Use `#Preview` blocks at the bottom of SwiftUI files. When a preview needs SwiftData, create an in-memory `ModelContainer` as in `Retainer Tracker/Views/HomeView.swift`.

**Linting:**
- Linting tool: Not detected.
- Follow the Swift API Design Guidelines as required by `CONTRIBUTING.md`.
- Keep public and app-facing internal types, methods, and properties documented with `///` comments. This pattern is used in `Retainer Tracker/Models/Session.swift`, `Retainer Tracker/Services/TimerEngine.swift`, and `Retainer Tracker/ViewModels/TimerViewModel.swift`.

## Import Organization

**Order:**
1. File header.
2. Apple framework imports, with the most relevant UI/framework import first for the file.
3. Type declaration and documentation.

Examples:
- Views import SwiftUI first, then supporting frameworks: `Retainer Tracker/Views/StatsView.swift` imports `SwiftUI`, `Charts`, then `SwiftData`.
- Models import data foundations first: `Retainer Tracker/Models/Session.swift` imports `Foundation` and `SwiftData`.
- Coordinators import the frameworks they bridge: `Retainer Tracker/ViewModels/TimerViewModel.swift` imports `SwiftUI`, `Combine`, `SwiftData`, and `WidgetKit`.
- Widget files import `WidgetKit`, `SwiftUI`, and `ActivityKit` where needed: `RetainerWidget/RetainerActivityWidget.swift`.

**Path Aliases:**
- Not applicable. The project uses app target membership and direct Swift module visibility, not custom path aliases.
- Package sources are mapped by `Package.swift` to the `Retainer Tracker/` path. Do not add import aliases or generated barrel files.

## Error Handling

**Patterns:**
- Use `do`/`catch` around platform setup or async API calls that produce a user-visible capability result: `ModelContainer` initialization in `Retainer Tracker/App/TrayOff.swift`, notification authorization in `Retainer Tracker/Services/NotificationService.swift`, and Live Activity creation in `Retainer Tracker/Services/LiveActivityManager.swift`.
- Use early `guard` exits for invalid no-op operations: `scheduleReminder(minutes:)` in `Retainer Tracker/Services/NotificationService.swift`, `update(...)` and `stop()` in `Retainer Tracker/Services/LiveActivityManager.swift`, `loadState()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use optional `try?` for best-effort persistence and timer sleeps where failure is intentionally non-fatal: `JSONEncoder().encode` and `JSONDecoder().decode` in `Retainer Tracker/Services/PersistenceService.swift`, `Task.sleep` in `Retainer Tracker/Services/TimerEngine.swift` and `Retainer Tracker/Services/ReminderManager.swift`.
- Keep persistence failures localized. `SessionManager.loadSessions()` catches SwiftData fetch errors and resets `sessions` to an empty array in `Retainer Tracker/Services/SessionManager.swift`.
- Reserve `fatalError` for unrecoverable app boot failures. The only app startup fatal path is `ModelContainer` creation in `Retainer Tracker/App/TrayOff.swift`.
- Keep UI methods non-throwing. Convert errors into state, `nil`, `false`, or no-op behavior inside services before they reach SwiftUI views.

## Logging

**Framework:** `console` via `print`

**Patterns:**
- Prefix console output with the component name. `Retainer Tracker/Services/NotificationService.swift` logs `[NotificationService] Failed to schedule notification: ...`.
- No structured logging framework is configured. Do not introduce ad hoc verbose logs in SwiftUI views.
- Prefer returning a value or updating observable state over printing when the caller can react, as in `requestPermissions() async -> Bool` in `Retainer Tracker/Services/NotificationService.swift`.

## Comments

**When to Comment:**
- Document every type and service method that forms part of the app architecture. `CONTRIBUTING.md` explicitly requires documentation comments for public types, methods, and properties, and the source applies this broadly to internal app types.
- Use `// MARK: -` comments to divide files into predictable sections. Keep these section names consistent with nearby files.
- Use short inline comments only for non-obvious platform behavior or algorithm intent, such as reconnecting Live Activities in `Retainer Tracker/Services/LiveActivityManager.swift` or restoring running timer state in `Retainer Tracker/Services/TimerEngine.swift`.
- Avoid comments that restate a single line of code. Prefer extracting a computed property or helper method when the explanation grows.

**JSDoc/TSDoc:**
- Not applicable. Use Swift documentation comments (`///`) with `- Parameter`, `- Parameters`, `- Returns`, and `- Note` fields where useful.
- Match the style in `Retainer Tracker/Models/Session.swift` and `Retainer Tracker/Services/PersistenceService.swift`.

## Function Design

**Size:** Keep app logic in service/view-model methods and keep SwiftUI view bodies focused on layout. Large screens may contain file-local helper views, but repeated layout pieces should move to `Retainer Tracker/Views/Components/`.

**Parameters:** Prefer explicit parameter labels and named callbacks. Use bindings for mutable view-owned state (`@Binding var selectedReminder`, `@Binding var showTimePicker`) and closures for user actions (`let onSelectReminder: (Int) -> Void`) in component APIs.

**Return Values:** Use concrete value returns for formatting and derived statistics:
- `TimeFormatter.format(_:) -> String` in `Retainer Tracker/Utils/TimeFormatter.swift`
- `TimerViewModel.getStatistics() -> (totalTime: Double, averageTime: Double, sessionCount: Int)` in `Retainer Tracker/ViewModels/TimerViewModel.swift`
- `TimerViewModel.getStreakStats() -> StreakStats` in `Retainer Tracker/ViewModels/TimerViewModel.swift`

**State Ownership:**
- App-level ownership starts in `Retainer Tracker/App/TrayOff.swift` with `@StateObject private var viewModel`.
- Root view access uses `@EnvironmentObject` in `Retainer Tracker/Views/ContentView.swift`.
- Child views receive `@ObservedObject var viewModel` when they need to observe app state, as in `Retainer Tracker/Views/HomeView.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Local presentation and editing state uses `@State`, such as `showSettingsSheet`, `showTimePicker`, `selectedSession`, and `isEditing`.
- UserDefaults-backed UI preferences use `@AppStorage`, as in `Retainer Tracker/Views/ContentView.swift`, or `@Published` with `didSet`, as in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `Retainer Tracker/Services/ReminderManager.swift`.

**Concurrency:**
- Use `Task<Void, Never>?` properties for cancellable background loops and cancel the existing task before starting a new one, matching `Retainer Tracker/Services/TimerEngine.swift` and `Retainer Tracker/Services/ReminderManager.swift`.
- Move observable updates back to the main actor from background tasks with `await MainActor.run`.
- Mark UI-facing coordinators that touch SwiftData or ActivityKit as `@MainActor`, as in `TimerViewModel`, `SessionManager`, and `LiveActivityManager`.

## Module Design

**Exports:** Swift files use default internal visibility unless a platform protocol requires broader access. `Retainer Tracker/Models/RetainerActivityAttributes.swift` exposes `public struct ContentState` for `ActivityAttributes`; most app types stay internal.

**Barrel Files:** Not used. Do not add barrel or umbrella Swift files. Add concrete files under the layer directories shown in `README.md` and referenced by `Package.swift`.

**Service Boundaries:**
- Define protocol interfaces before concrete service implementations when the service coordinates state or persistence: `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/ReminderManager.swift`, `Retainer Tracker/Services/PersistenceService.swift`.
- Keep platform singletons narrow and explicit. Existing singletons are `NotificationService.shared` in `Retainer Tracker/Services/NotificationService.swift` and `LiveActivityManager.shared` in `Retainer Tracker/Services/LiveActivityManager.swift`.
- Keep business orchestration in `TimerViewModel`, not in SwiftUI views. Views call methods such as `toggleTimer()`, `deleteSession(_:)`, and `updateSession(_:)`.

**SwiftUI Components:**
- Reuse `AppConfig` constants for dimensions, spacing, corner radii, and animation timings instead of duplicating literals in new reusable components.
- Use SF Symbols through `Image(systemName:)`, as in `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, and `RetainerWidget/RetainerActivityWidget.swift`.
- Keep previews close to the view they exercise and use in-memory SwiftData containers when a view needs `Session` or `TimerViewModel`.

---

*Convention analysis: 2026-05-02*
