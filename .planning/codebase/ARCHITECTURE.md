---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: arch
---
<!-- refreshed: 2026-05-02 -->
# Architecture

**Analysis Date:** 2026-05-02

## System Overview

```text
iOS application target: TrayOff
`Retainer Tracker/App/TrayOff.swift`
        |
        v
SwiftUI root and screens
`Retainer Tracker/Views/ContentView.swift`
`Retainer Tracker/Views/HomeView.swift`
`Retainer Tracker/Views/StatsView.swift`
`Retainer Tracker/Views/SettingsView.swift`
        |
        v
Main-actor state coordinator
`Retainer Tracker/ViewModels/TimerViewModel.swift`
        |
        +----------------------+----------------------+----------------------+
        |                      |                      |                      |
        v                      v                      v                      v
Timer/session services     Reminder services      Activity services      Persistence
`Retainer Tracker/Services/TimerEngine.swift`
`Retainer Tracker/Services/SessionManager.swift`
`Retainer Tracker/Services/ReminderManager.swift`
`Retainer Tracker/Services/NotificationService.swift`
`Retainer Tracker/Services/LiveActivityManager.swift`
`Retainer Tracker/Services/PersistenceService.swift`
        |                      |                      |                      |
        v                      v                      v                      v
SwiftData                  UserNotifications       ActivityKit             App Group UserDefaults
`Retainer Tracker/Models/Session.swift`
`Retainer Tracker/Models/RetainerActivityAttributes.swift`
`Retainer Tracker/Retainer Tracker.entitlements`
`RetainerWidgetExtension.entitlements`
        |
        v
Widget extension target: RetainerWidgetExtension
`RetainerWidget/RetainerWidgetBundle.swift`
`RetainerWidget/RetainerWidget.swift`
`RetainerWidget/RetainerActivityWidget.swift`
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| App bootstrap | Creates the SwiftData `ModelContainer`, constructs `TimerViewModel`, injects it into SwiftUI, and routes scene phase events. | `Retainer Tracker/App/TrayOff.swift` |
| Root navigation | Owns the Home/Stats `TabView`, first-launch onboarding state, and startup notification permission request. | `Retainer Tracker/Views/ContentView.swift` |
| Home screen | Presents the timer status, progress ring, timer action, undo action, settings sheet, and goal status overlay. | `Retainer Tracker/Views/HomeView.swift` |
| Stats screen | Presents streaks, history chart, today's session list, edit sheet, and delete actions. | `Retainer Tracker/Views/StatsView.swift` |
| Settings screen | Edits goal, danger, reminder, and goal-status preferences through bindings to the view model. | `Retainer Tracker/Views/SettingsView.swift` |
| Timer coordinator | Central `@MainActor` `ObservableObject`; binds service publishers, exposes screen state, performs timer commands, persists state, and reloads widgets. | `Retainer Tracker/ViewModels/TimerViewModel.swift` |
| Timer engine | Tracks elapsed time using system uptime and publishes running/progress state from an internal task. | `Retainer Tracker/Services/TimerEngine.swift` |
| Session manager | Owns SwiftData CRUD for `Session` and publishes the in-memory session list. | `Retainer Tracker/Services/SessionManager.swift` |
| Reminder manager | Owns reminder countdown state and delegates system notification scheduling/cancellation. | `Retainer Tracker/Services/ReminderManager.swift` |
| Notification service | Singleton wrapper for local notification permission, scheduling, and cancellation. | `Retainer Tracker/Services/NotificationService.swift` |
| Live Activity manager | Singleton wrapper for ActivityKit request, update, reconnect, and end operations. | `Retainer Tracker/Services/LiveActivityManager.swift` |
| Timer persistence | Encodes `TimerState` as JSON in App Group `UserDefaults` under `timerState`. | `Retainer Tracker/Services/PersistenceService.swift` |
| SwiftData model | Records retainer-off sessions with `start`, `end`, `id`, and computed `duration`. | `Retainer Tracker/Models/Session.swift` |
| Activity attributes | Defines the ActivityKit contract shared by app and widget extension. | `Retainer Tracker/Models/RetainerActivityAttributes.swift` |
| Home widget | Reads App Group timer state and renders a small WidgetKit timeline entry. | `RetainerWidget/RetainerWidget.swift` |
| Live Activity widget | Renders Lock Screen and Dynamic Island ActivityKit UI from `RetainerActivityAttributes`. | `RetainerWidget/RetainerActivityWidget.swift` |
| Widget bundle | Widget extension `@main` entry point. | `RetainerWidget/RetainerWidgetBundle.swift` |

## Pattern Overview

**Overall:** SwiftUI MVVM with a service-backed state coordinator and a separate WidgetKit extension.

**Key Characteristics:**
- Keep screen state and commands in `Retainer Tracker/ViewModels/TimerViewModel.swift`; views call methods and render `@Published` state.
- Keep platform APIs behind services in `Retainer Tracker/Services/` so SwiftUI screens do not talk directly to SwiftData, ActivityKit, WidgetKit, or `UNUserNotificationCenter`.
- Treat `RetainerWidget/` as an extension boundary. It does not use `TimerViewModel`; it reads the App Group `TimerState` payload and ActivityKit attributes.
- Keep cross-target contracts simple and codable. `RetainerActivityAttributes` lives in `Retainer Tracker/Models/RetainerActivityAttributes.swift` and is shared with the widget target through Xcode target membership.

## Layers

**Bootstrap Layer:**
- Purpose: Start the app scene, initialize persistence, and install environment dependencies.
- Location: `Retainer Tracker/App/TrayOff.swift`
- Contains: `TrayOffApp`, `ModelContainer`, scene phase routing.
- Depends on: `SwiftUI`, `SwiftData`, `Session`, `TimerViewModel`.
- Used by: iOS app process entry point from `TrayOff.xcodeproj/project.pbxproj`.

**View Layer:**
- Purpose: Render screens and translate user gestures into view-model commands.
- Location: `Retainer Tracker/Views/`
- Contains: `ContentView`, `HomeView`, `StatsView`, `SettingsView`, `OnboardingView`, and reusable components under `Retainer Tracker/Views/Components/`.
- Depends on: `TimerViewModel`, `Session`, `TimeFormatter`, `AppConfig`, SwiftUI, Swift Charts.
- Used by: `TrayOffApp` and SwiftUI previews inside individual view files.

**ViewModel Layer:**
- Purpose: Coordinate all timer use cases, bind service output to UI state, compute statistics, and persist timer snapshots.
- Location: `Retainer Tracker/ViewModels/TimerViewModel.swift`
- Contains: `TimerViewModel`, published app state, public commands, Combine subscriptions, midnight rollover logic.
- Depends on: `TimerEngine`, `SessionManager`, `ReminderManager`, `TimerPersistenceServiceProtocol`, `LiveActivityManager`, `WidgetCenter`, `ModelContext`.
- Used by: `ContentView`, `HomeView`, `StatsView`, `SettingsView`, and timer components.

**Service Layer:**
- Purpose: Isolate platform effects and long-running timer/reminder tasks.
- Location: `Retainer Tracker/Services/`
- Contains: `TimerEngine`, `SessionManager`, `ReminderManager`, `NotificationService`, `LiveActivityManager`, `TimerPersistenceService`.
- Depends on: `SwiftData`, `Combine`, `ActivityKit`, `UserNotifications`, `WidgetKit` indirectly through the view model, and App Group `UserDefaults`.
- Used by: `TimerViewModel` and `ContentView` for permission request.

**Model Layer:**
- Purpose: Define persisted and shared domain records.
- Location: `Retainer Tracker/Models/`
- Contains: `Session` SwiftData model and `RetainerActivityAttributes` ActivityKit contract.
- Depends on: `SwiftData`, `ActivityKit`, `Foundation`.
- Used by: app services, SwiftData container setup, and widget ActivityKit UI.

**Widget Extension Layer:**
- Purpose: Render WidgetKit home-screen widget and ActivityKit Dynamic Island/Lock Screen surfaces.
- Location: `RetainerWidget/`
- Contains: `RetainerWidgetBundle`, `RetainerWidget`, `RetainerActivityWidget`, widget-only display helpers.
- Depends on: `WidgetKit`, `SwiftUI`, `ActivityKit`, App Group `UserDefaults`, and shared `RetainerActivityAttributes`.
- Used by: `RetainerWidgetExtension` target configured in `TrayOff.xcodeproj/project.pbxproj`.

**Configuration and Assets Layer:**
- Purpose: Store constants, formatting helpers, Info.plist files, entitlements, asset catalogs, and app icon assets.
- Location: `Retainer Tracker/Utils/`, `Retainer-Tracker-Info.plist`, `Retainer Tracker/Retainer Tracker.entitlements`, `RetainerWidget/Info.plist`, `RetainerWidgetExtension.entitlements`, `Retainer Tracker/Assets.xcassets/`, `RetainerWidget/Assets.xcassets/`, `TrayOff.icon/`
- Contains: `AppConfig`, `TimeFormatter`, bundle metadata, App Group entitlements, launch image, accent colors, widget colors, and app icon layers.
- Depends on: Xcode build settings in `TrayOff.xcodeproj/project.pbxproj`.
- Used by: app target, widget target, and SwiftUI views.

## Data Flow

### Primary App Launch Path

1. iOS launches `TrayOffApp` from `Retainer Tracker/App/TrayOff.swift:17`.
2. `TrayOffApp.init()` creates `Schema([Session.self])`, a persistent `ModelContainer`, and `TimerViewModel(modelContext:)` in `Retainer Tracker/App/TrayOff.swift:32`.
3. `ContentView` receives the view model with `.environmentObject(viewModel)` and the SwiftData container with `.modelContainer(container)` in `Retainer Tracker/App/TrayOff.swift:49`.
4. `ContentView` builds Home and Stats tabs and requests notification permission in `Retainer Tracker/Views/ContentView.swift:26`.
5. Scene phase changes call `appDidBecomeActive()` or `appWillBecomeInactive()` in `Retainer Tracker/App/TrayOff.swift:54`.

### Timer Start/Stop Path

1. `HomeView` passes `viewModel.toggleTimer()` into `TimerRingView` in `Retainer Tracker/Views/HomeView.swift:36`.
2. `TimerButtonView` invokes the action when the circular timer button is tapped in `Retainer Tracker/Views/Components/TimerButtonView.swift:74`.
3. `TimerViewModel.toggleTimer()` calls `timerEngine.toggle()` in `Retainer Tracker/ViewModels/TimerViewModel.swift:132`.
4. When running starts, `TimerViewModel` records `currentSessionStart`, starts the reminder countdown, and starts a Live Activity in `Retainer Tracker/ViewModels/TimerViewModel.swift:135`.
5. When running stops, `TimerViewModel` inserts a `Session`, stops reminders, stops the Live Activity, and saves state in `Retainer Tracker/ViewModels/TimerViewModel.swift:143`.
6. `TimerPersistenceService.saveTimerState(_:)` writes JSON to App Group `UserDefaults` in `Retainer Tracker/Services/PersistenceService.swift:82`.
7. `WidgetCenter.shared.reloadAllTimelines()` requests widget refresh in `Retainer Tracker/ViewModels/TimerViewModel.swift:371`.

### Timer Tick and UI Update Path

1. `TimerEngine.start()` records wall-clock and system uptime start values in `Retainer Tracker/Services/TimerEngine.swift:76`.
2. `TimerEngine.startTimerTask()` runs a cancellable `Task` loop using `AppConfig.Timer.updateInterval` in `Retainer Tracker/Services/TimerEngine.swift:159`.
3. The task publishes `currentProgress` on the main actor in `Retainer Tracker/Services/TimerEngine.swift:164`.
4. `TimerViewModel.setupBindings()` copies `timerEngine.$currentProgress` into `TimerViewModel.currentProgress` and checks midnight rollover in `Retainer Tracker/ViewModels/TimerViewModel.swift:313`.
5. `HomeView`, `StatusView`, `ActivityRing`, and `GoalStatusView` render the new progress through observed SwiftUI state in `Retainer Tracker/Views/HomeView.swift:31`.

### Session and Statistics Path

1. `SessionManager.addSession(start:end:)` inserts `Session` into SwiftData and reloads sessions in `Retainer Tracker/Services/SessionManager.swift:67`.
2. `SessionManager.loadSessions()` fetches sessions sorted by `start` in `Retainer Tracker/Services/SessionManager.swift:113`.
3. `TimerViewModel.setupBindings()` assigns `sessionManager.$sessions` to `TimerViewModel.sessions` in `Retainer Tracker/ViewModels/TimerViewModel.swift:321`.
4. `StatsView` renders `viewModel.todaySessions`, `StatsSummaryView`, and `HistoryView` in `Retainer Tracker/Views/StatsView.swift:30`.
5. Session edits and deletes route back through `TimerViewModel.updateSession(_:)` and `TimerViewModel.deleteSession(_:)` in `Retainer Tracker/ViewModels/TimerViewModel.swift:281`.
6. Session mutations call `recalculateAccumulatedTime()` and persist the corrected timer state in `Retainer Tracker/ViewModels/TimerViewModel.swift:330`.

### Widget and Live Activity Path

1. `TimerViewModel.saveState()` persists `TimerState` with `goal` and `danger` in `Retainer Tracker/ViewModels/TimerViewModel.swift:358`.
2. `Provider.loadEntry()` opens `UserDefaults(suiteName: "group.com.TrayOff.shared")` and decodes the same `timerState` key in `RetainerWidget/RetainerWidget.swift:51`.
3. `Provider.getTimeline(in:completion:)` returns a single timeline entry with a 15-minute refresh policy in `RetainerWidget/RetainerWidget.swift:42`.
4. `RetainerWidgetEntryView` renders status, elapsed time, and `WidgetActivityRing` from `SimpleEntry` in `RetainerWidget/RetainerWidget.swift:139`.
5. `LiveActivityManager.start(accumulatedTime:goal:danger:)` requests an ActivityKit activity using `RetainerActivityAttributes` in `Retainer Tracker/Services/LiveActivityManager.swift:44`.
6. `RetainerActivityWidget` renders Lock Screen and Dynamic Island surfaces from `ActivityConfiguration(for: RetainerActivityAttributes.self)` in `RetainerWidget/RetainerActivityWidget.swift:22`.

**State Management:**
- Use `TimerViewModel` as the single screen-facing state owner for timer state, sessions, reminder countdown, goal, danger, and goal-status visibility in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use SwiftData for historical sessions through `Session` in `Retainer Tracker/Models/Session.swift`.
- Use App Group `UserDefaults` for widget-readable timer snapshots through `TimerPersistenceService` in `Retainer Tracker/Services/PersistenceService.swift`.
- Use `@AppStorage("hasSeenOnboarding")` only for onboarding presentation state in `Retainer Tracker/Views/ContentView.swift`.
- Use `UserDefaults.standard` only for simple app preferences such as `selectedReminder` in `Retainer Tracker/Services/ReminderManager.swift` and `showGoalStatus` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.

## Key Abstractions

**`TimerViewModel`:**
- Purpose: Application use-case facade for screens.
- Examples: `Retainer Tracker/ViewModels/TimerViewModel.swift`, `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`
- Pattern: `@MainActor ObservableObject` with constructor-injected services and Combine bindings.

**`Session`:**
- Purpose: Persisted retainer-off interval.
- Examples: `Retainer Tracker/Models/Session.swift`, `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Views/StatsView.swift`
- Pattern: SwiftData `@Model` with computed `duration`.

**`TimerState`:**
- Purpose: Codable snapshot of active timer state for launch restore and widget sharing.
- Examples: `Retainer Tracker/Services/PersistenceService.swift`, `RetainerWidget/RetainerWidget.swift`
- Pattern: JSON-encoded App Group `UserDefaults` payload under key `timerState`.

**`RetainerActivityAttributes`:**
- Purpose: Shared ActivityKit contract for Live Activity state.
- Examples: `Retainer Tracker/Models/RetainerActivityAttributes.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`, `RetainerWidget/RetainerActivityWidget.swift`
- Pattern: `ActivityAttributes` with nested codable/hashable `ContentState`.

**Service Protocols:**
- Purpose: Define testable contracts for timer, session, reminder, and persistence behavior.
- Examples: `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Services/ReminderManager.swift`, `Retainer Tracker/Services/PersistenceService.swift`
- Pattern: Protocol plus concrete class for service implementation; `TimerViewModel` constructor injects timer/reminder/persistence services.

**Widget Timeline Entry:**
- Purpose: Immutable display record for home-screen widget rendering.
- Examples: `RetainerWidget/RetainerWidget.swift`
- Pattern: `TimelineProvider` loads App Group state and maps it into `SimpleEntry`.

## Entry Points

**iOS App:**
- Location: `Retainer Tracker/App/TrayOff.swift`
- Triggers: App launch through `TrayOff` application target in `TrayOff.xcodeproj/project.pbxproj`.
- Responsibilities: Bootstrap SwiftData, create `TimerViewModel`, install environment state, route scene phase events.

**Root SwiftUI UI:**
- Location: `Retainer Tracker/Views/ContentView.swift`
- Triggers: `WindowGroup` body from `TrayOffApp`.
- Responsibilities: Tabs, onboarding presentation, notification permission request.

**Timer Interaction:**
- Location: `Retainer Tracker/Views/Components/TimerButtonView.swift`
- Triggers: Tap and long-press gestures from the Home screen.
- Responsibilities: Start/stop timer action and reminder duration picker.

**Widget Extension:**
- Location: `RetainerWidget/RetainerWidgetBundle.swift`
- Triggers: WidgetKit loads `RetainerWidgetExtension`.
- Responsibilities: Register the static widget and Live Activity widget.

**Home-Screen Widget Timeline:**
- Location: `RetainerWidget/RetainerWidget.swift`
- Triggers: WidgetKit timeline snapshot or refresh.
- Responsibilities: Decode shared `TimerState` and render `RetainerWidgetEntryView`.

**Live Activity UI:**
- Location: `RetainerWidget/RetainerActivityWidget.swift`
- Triggers: ActivityKit activity request from `LiveActivityManager`.
- Responsibilities: Render Lock Screen, banner, and Dynamic Island regions.

## Architectural Constraints

- **Platform target:** Xcode build settings set `IPHONEOS_DEPLOYMENT_TARGET = 26.0` for `TrayOff` and `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`; app and widget entry points are annotated with `@available(iOS 26.0, *)` in `Retainer Tracker/App/TrayOff.swift`, `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerActivityWidget.swift`, and `RetainerWidget/RetainerWidgetBundle.swift`.
- **Threading:** `TimerViewModel` and `SessionManager` are `@MainActor` in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `Retainer Tracker/Services/SessionManager.swift`. `TimerEngine` and `ReminderManager` use cancellable `Task<Void, Never>` loops and dispatch published changes onto `MainActor` in `Retainer Tracker/Services/TimerEngine.swift` and `Retainer Tracker/Services/ReminderManager.swift`.
- **Global state:** `NotificationService.shared` in `Retainer Tracker/Services/NotificationService.swift`, `LiveActivityManager.shared` in `Retainer Tracker/Services/LiveActivityManager.swift`, `WidgetCenter.shared` usage in `Retainer Tracker/ViewModels/TimerViewModel.swift`, `UserDefaults.standard` usage in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `Retainer Tracker/Services/ReminderManager.swift`, and App Group `UserDefaults` in `Retainer Tracker/Services/PersistenceService.swift` are process-global dependencies.
- **Cross-target boundary:** The widget target code in `RetainerWidget/` must not depend on `TimerViewModel` or app services. Share widget state through App Group `UserDefaults` in `Retainer Tracker/Services/PersistenceService.swift` and ActivityKit contracts in `Retainer Tracker/Models/RetainerActivityAttributes.swift`.
- **Xcode membership:** `TrayOff.xcodeproj/project.pbxproj` uses `PBXFileSystemSynchronizedRootGroup` entries for `Retainer Tracker/` and `RetainerWidget/`. Files added under `Retainer Tracker/` belong to the app target; files added under `RetainerWidget/` belong to the widget extension. Shared files need explicit target membership, as with `Retainer Tracker/Models/RetainerActivityAttributes.swift`.
- **Circular imports:** Not detected. Swift files in the same target module reference each other directly; cross-target references are limited to target membership and App Group serialization.
- **SwiftPM package:** `Package.swift` exposes `Retainer Tracker/` as a library target named `TrayOff`; the app and widget architecture is controlled by `TrayOff.xcodeproj/project.pbxproj`.

## Anti-Patterns

### Duplicated Shared Payload Schemas

**What happens:** `TimerState` is declared in both `Retainer Tracker/Services/PersistenceService.swift` and `RetainerWidget/RetainerWidget.swift`.

**Why it's wrong:** App and widget decoding stay coupled by field names and types without compiler-enforced sharing, so a payload change can make `Provider.loadEntry()` fail to decode shared state.

**Do this instead:** For new shared payloads, create one extension-safe model file and include it in both targets, following the target-membership pattern used by `Retainer Tracker/Models/RetainerActivityAttributes.swift`.

### Deep Component Coupling To `TimerViewModel`

**What happens:** `TimerRingView` and `TimerButtonView` receive scalar props and callbacks but also hold `@ObservedObject var viewModel` in `Retainer Tracker/Views/Components/TimerRingView.swift` and `Retainer Tracker/Views/Components/TimerButtonView.swift`.

**Why it's wrong:** Reusable UI components become coupled to the whole app state surface, increasing redraw scope and making isolated preview/test setup heavier.

**Do this instead:** Keep `TimerViewModel` ownership at screen boundaries such as `Retainer Tracker/Views/HomeView.swift`; pass narrow values, bindings, and callbacks into components under `Retainer Tracker/Views/Components/`.

## Error Handling

**Strategy:** Startup persistence failures fail fast; runtime platform-service failures fail closed and keep the UI responsive.

**Patterns:**
- `TrayOffApp.init()` uses `fatalError` if `ModelContainer` cannot be created in `Retainer Tracker/App/TrayOff.swift`.
- `SessionManager` uses `try?` or fallback empty sessions for SwiftData failures in `Retainer Tracker/Services/SessionManager.swift`.
- `TimerPersistenceService` returns `nil` when the App Group payload cannot decode in `Retainer Tracker/Services/PersistenceService.swift`.
- `NotificationService.requestPermissions()` returns `false` on authorization errors in `Retainer Tracker/Services/NotificationService.swift`.
- `LiveActivityManager.start()` catches ActivityKit request errors without surfacing UI state in `Retainer Tracker/Services/LiveActivityManager.swift`.
- `NotificationService.scheduleReminder(minutes:)` logs scheduling failures with `print` in `Retainer Tracker/Services/NotificationService.swift`.

## Cross-Cutting Concerns

**Logging:** Console logging is limited to notification scheduling failure in `Retainer Tracker/Services/NotificationService.swift`; other service errors are silent or represented by fallback state.

**Validation:** UI controls constrain values locally: `SettingsView` clamps goal and danger sliders in `Retainer Tracker/Views/SettingsView.swift`, `EditSessionView` constrains `endDate` to `startDate...` in `Retainer Tracker/Views/StatsView.swift`, and `NotificationService` skips zero-minute reminders in `Retainer Tracker/Services/NotificationService.swift`.

**Authentication:** Not applicable. No authentication or identity layer is present in `Retainer Tracker/`, `RetainerWidget/`, or `TrayOff.xcodeproj/project.pbxproj`.

**Persistence:** Historical sessions use SwiftData through `SessionManager` in `Retainer Tracker/Services/SessionManager.swift`; active timer state and widget state use App Group `UserDefaults` through `TimerPersistenceService` in `Retainer Tracker/Services/PersistenceService.swift`; simple preferences use `UserDefaults.standard` and `@AppStorage`.

---

*Architecture analysis: 2026-05-02*
