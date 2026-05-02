<!-- GSD:project-start source:PROJECT.md -->
## Project

**TrayOff App Store Polish**

TrayOff is an iOS app for tracking the amount of time a user has their retainer off. The core app already exists: users can start and stop a timer, record retainer-off sessions, see today's stats, adjust goals and reminders, use a widget, and see Live Activity status. This project turns that finished core into a more polished App Store app, then grows it with history, better statistics, and a more useful Live Activity.

**Core Value:** TrayOff must make retainer-off time easy to track, review, and trust so users can build a healthier daily habit.

### Constraints

- **Platform**: iOS app plus WidgetKit extension - changes must respect app and extension target boundaries.
- **Tech stack**: SwiftUI, SwiftData, WidgetKit, ActivityKit, Combine, UserNotifications - prefer existing Apple framework patterns already in the codebase.
- **Build surface**: Use `TrayOff.xcodeproj` as the source of truth for app/widget work; `Package.swift` is stale for full app builds.
- **Design scope**: Tighten the current UI rather than creating a new marketing-style redesign.
- **Data integrity**: History and stats must treat cross-day sessions and midnight rollover carefully before presenting broader historical insights.
- **Verification**: A full Xcode installation is required for `xcodebuild`; this shell currently has Command Line Tools only.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Swift - Main application, widget extension, models, services, and views live under `Retainer Tracker/` and `RetainerWidget/`.
- Swift language mode 5.0 - Xcode build settings set `SWIFT_VERSION = 5.0` for `TrayOff` and `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`.
- Swift tools 5.3 - Swift Package Manager manifest declares `// swift-tools-version:5.3` in `Package.swift`.
- XML property lists - App, extension, and entitlement configuration in `Retainer-Tracker-Info.plist`, `RetainerWidget/Info.plist`, `Retainer Tracker/Retainer Tracker.entitlements`, and `RetainerWidgetExtension.entitlements`.
- JSON asset catalogs - Xcode-managed asset metadata under `Retainer Tracker/Assets.xcassets/`, `RetainerWidget/Assets.xcassets/`, and `TrayOff.icon/icon.json`.
- Markdown - Project documentation in `README.md`, `CONTRIBUTING.md`, and `LICENSE`.
## Runtime
- iOS application runtime - Main target `TrayOff` builds an iPhone app with `SDKROOT = iphoneos`, `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`, and `TARGETED_DEVICE_FAMILY = 1` in `TrayOff.xcodeproj/project.pbxproj`.
- Widget extension runtime - Target `RetainerWidgetExtension` builds an app extension with `productType = "com.apple.product-type.app-extension"` and `NSExtensionPointIdentifier = com.apple.widgetkit-extension` in `TrayOff.xcodeproj/project.pbxproj` and `RetainerWidget/Info.plist`.
- Deployment target 26.0 for shipping targets - `IPHONEOS_DEPLOYMENT_TARGET = 26.0` is set on `TrayOff` and `RetainerWidgetExtension` target build configurations in `TrayOff.xcodeproj/project.pbxproj`.
- Project-level deployment target 18.2 - Project build configurations set `IPHONEOS_DEPLOYMENT_TARGET = 18.2` in `TrayOff.xcodeproj/project.pbxproj`; target-level settings override this for the app and widget.
- Source availability gates - App and widget entry points use `@available(iOS 26.0, *)` in `Retainer Tracker/App/TrayOff.swift`, `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerActivityWidget.swift`, and `RetainerWidget/RetainerWidgetBundle.swift`.
- Local CLI observed during mapping - `swift --version` reports Apple Swift 6.2.4; `xcodebuild` is unavailable because the active developer directory is Command Line Tools rather than a full Xcode app.
- Swift Package Manager - `Package.swift` defines package `TrayOff`, product `TrayOff`, and target `TrayOff` with path `Retainer Tracker`.
- Lockfile: missing - No `Package.resolved` detected.
- External package dependencies: none - `Package.swift` has `dependencies: []` and target `dependencies: []`.
## Frameworks
- SwiftUI - Main UI framework imported by app views and components such as `Retainer Tracker/App/TrayOff.swift`, `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, and `RetainerWidget/RetainerWidget.swift`.
- SwiftData - Local model persistence for `Session` via `@Model` in `Retainer Tracker/Models/Session.swift`, initialized in `Retainer Tracker/App/TrayOff.swift`, and used by `Retainer Tracker/Services/SessionManager.swift`.
- WidgetKit - Home screen widget and timeline reload support in `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerWidgetBundle.swift`, and `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- ActivityKit - Live Activity attributes, manager, and Dynamic Island/Lock Screen widget UI in `Retainer Tracker/Models/RetainerActivityAttributes.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`, and `RetainerWidget/RetainerActivityWidget.swift`.
- Combine - Observable timer and reminder state bindings in `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/ReminderManager.swift`, and `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Charts - Statistics visualization in `Retainer Tracker/Views/StatsView.swift`.
- UserNotifications - Local reminder permission requests, scheduling, and cancellation in `Retainer Tracker/Services/NotificationService.swift`.
- XCTest target: Not detected.
- Swift Testing target: Not detected.
- Test files: Not detected. No `*.test.swift`, `*Tests.swift`, or `*.spec.swift` files are present.
- Xcode project - `TrayOff.xcodeproj/project.pbxproj` is the app build source of truth for targets, signing, entitlements, Info.plist generation, assets, deployment target, and embedded extension.
- SwiftPM manifest - `Package.swift` exposes the app sources as a library package named `TrayOff`; use it for package-level tooling only because the app/widget packaging is defined in `TrayOff.xcodeproj/project.pbxproj`.
- Xcode asset catalogs - App assets in `Retainer Tracker/Assets.xcassets/` and widget assets in `RetainerWidget/Assets.xcassets/`.
- Generated Info.plist settings - Build settings use `GENERATE_INFOPLIST_FILE = YES` while also pointing at `Retainer-Tracker-Info.plist` and `RetainerWidget/Info.plist`.
## Key Dependencies
- Apple SDK frameworks - The application depends entirely on Apple platform frameworks declared through Swift imports and Xcode framework references in `TrayOff.xcodeproj/project.pbxproj`.
- SwiftData - Required for persisted session history; add new persisted domain models next to `Retainer Tracker/Models/Session.swift` and register them in the `Schema` created in `Retainer Tracker/App/TrayOff.swift`.
- WidgetKit + App Groups - Required for widget display of timer state; shared state is encoded in `Retainer Tracker/Services/PersistenceService.swift` and decoded in `RetainerWidget/RetainerWidget.swift`.
- ActivityKit - Required for Live Activities and Dynamic Island surfaces; activity state shape is defined in `Retainer Tracker/Models/RetainerActivityAttributes.swift`.
- UserNotifications - Required for local reminder alerts; scheduling is centralized in `Retainer Tracker/Services/NotificationService.swift`.
- Application Groups entitlement - `group.com.TrayOff.shared` is declared in both `Retainer Tracker/Retainer Tracker.entitlements` and `RetainerWidgetExtension.entitlements`.
- Automatic code signing - `CODE_SIGN_STYLE = Automatic` and `DEVELOPMENT_TEAM = QXMDCMDF8D` are set in `TrayOff.xcodeproj/project.pbxproj`.
- Bundle identifiers - Main app uses `com.cristopher.TrayOff`; widget extension uses `com.cristopher.TrayOff.Widget` in `TrayOff.xcodeproj/project.pbxproj`.
- App versioning - `MARKETING_VERSION = 1.1` and `CURRENT_PROJECT_VERSION = 1` are set in `TrayOff.xcodeproj/project.pbxproj`.
## Configuration
- No `.env`, `.env.*`, credential, certificate, or package-auth files detected at repo depth 3.
- Runtime configuration is source-based through constants in `Retainer Tracker/Utils/AppConfig.swift`, persisted user preferences in `UserDefaults`, and Xcode build settings in `TrayOff.xcodeproj/project.pbxproj`.
- Timer state persistence key is `timerState` in `Retainer Tracker/Services/PersistenceService.swift`; widget reads the same key in `RetainerWidget/RetainerWidget.swift`.
- Shared app group suite is `group.com.TrayOff.shared` in `Retainer Tracker/Services/PersistenceService.swift`, `RetainerWidget/RetainerWidget.swift`, `Retainer Tracker/Retainer Tracker.entitlements`, and `RetainerWidgetExtension.entitlements`.
- App target: `TrayOff` in `TrayOff.xcodeproj/project.pbxproj`.
- Widget target: `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`.
- SwiftPM package: `Package.swift`.
- App Info.plist: `Retainer-Tracker-Info.plist`.
- Widget Info.plist: `RetainerWidget/Info.plist`.
- App entitlements: `Retainer Tracker/Retainer Tracker.entitlements`.
- Widget entitlements: `RetainerWidgetExtension.entitlements`.
- App icons and launch imagery: `Retainer Tracker/Assets.xcassets/`, `RetainerWidget/Assets.xcassets/`, and `TrayOff.icon/`.
## Platform Requirements
- Use a full Xcode installation to build and inspect schemes; the current active developer directory exposes Command Line Tools only, so `xcodebuild -version` and `xcodebuild -list -project TrayOff.xcodeproj` fail in this shell.
- Open `TrayOff.xcodeproj` for app development because it defines the app target, widget extension target, signing, entitlements, resources, and embedded extension.
- Keep new app code under `Retainer Tracker/` and new widget code under `RetainerWidget/` so the Xcode file system synchronized groups include the files without manual project edits.
- Preserve SwiftUI preview-only model containers in view files such as `Retainer Tracker/Views/ContentView.swift`, `Retainer Tracker/Views/HomeView.swift`, and `Retainer Tracker/Views/StatsView.swift` when adding UI previews.
- Deployment target is iOS 26.0 for both the `TrayOff` app and `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`.
- Distribution uses Apple code signing and bundle IDs configured in `TrayOff.xcodeproj/project.pbxproj`.
- No CI/CD, Fastlane, or hosted deployment configuration detected.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- Use `PascalCase.swift` and match the primary type name: `Retainer Tracker/ViewModels/TimerViewModel.swift`, `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Views/HomeView.swift`.
- Place SwiftUI component files under `Retainer Tracker/Views/Components/` and name them after the component type: `Retainer Tracker/Views/Components/ActivityRing.swift`, `Retainer Tracker/Views/Components/TimerButtonView.swift`.
- Widget files live under `RetainerWidget/` and use widget-specific type names: `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerActivityWidget.swift`, `RetainerWidget/RetainerWidgetBundle.swift`.
- Keep related small helper views in the same feature file when they are private to one screen workflow, as in `Retainer Tracker/Views/StatsView.swift` with `StatsSummaryView`, `StatItemView`, `SessionItemView`, `HistoryView`, and `EditSessionView`.
- Use lower camel case and verb-first names for actions: `toggleTimer()`, `resetTimer()`, `undoLastSession()`, `deleteAllTodaySessions()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use query-style names for computed data: `getStatistics()`, `getStreakStats()`, `getHistoryData()` in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Use callback labels beginning with `on` for view actions: `onButtonTap`, `onSelectReminder`, `onSave`, `onDelete`, `onCancel` in `Retainer Tracker/Views/Components/TimerRingView.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Keep private helpers under a `// MARK: - Private Methods` section: `formatCountdown(_:)` in `Retainer Tracker/Views/Components/TimerButtonView.swift`, `saveState()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use lower camel case for stored and local values: `currentProgress`, `selectedReminder`, `showGoalStatus`, `currentSessionStart`, `lastResetDate` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use boolean prefixes that read naturally: `isRunning`, `isEditing`, `showTimePicker`, `showDeleteConfirmation`, `hasSeenOnboarding` in `Retainer Tracker/Views/StatsView.swift`, `Retainer Tracker/Views/HomeView.swift`, and `Retainer Tracker/Views/ContentView.swift`.
- Use `private(set)` for observable state that views may read but external callers should not mutate: `@Published private(set) var isRunning`, `currentProgress`, and `sessions` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Store shared constants as `static let` inside nested namespace enums rather than free globals: `AppConfig.Timer.defaultGoal`, `AppConfig.UI.ringSize`, `AppConfig.Animation.standard` in `Retainer Tracker/Utils/AppConfig.swift`.
- Use UpperCamelCase for structs, classes, enums, and protocols: `Session`, `TimerEngine`, `TimerEngineProtocol`, `TimerPersistenceServiceProtocol`, `WidgetStatus`.
- Suffix protocols with `Protocol` when they describe a service dependency: `SessionManagerProtocol`, `TimerEngineProtocol`, `ReminderManagerProtocol`, `TimerPersistenceServiceProtocol` in `Retainer Tracker/Services/`.
- Suffix state coordinators with `ViewModel`: `TimerViewModel` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Suffix platform service wrappers with `Manager` or `Service`: `SessionManager`, `ReminderManager`, `LiveActivityManager`, `NotificationService`, `TimerPersistenceService` in `Retainer Tracker/Services/`.
- Use nested enums for local phases or categories: `RingPhase` in `Retainer Tracker/Views/Components/ActivityRing.swift`, `AppConfig.Timer` in `Retainer Tracker/Utils/AppConfig.swift`.
## Code Style
- Formatter config: Not detected. No `.swift-format`, `.swiftformat`, `.swiftlint.yml`, or `.editorconfig` files are present.
- Use Xcode-style Swift formatting: 4-space indentation, opening braces on the declaration line, blank lines between logical sections, and trailing multiline argument lists for complex SwiftUI initializers.
- Keep the standard file header at the top of Swift files, matching `Retainer Tracker/App/TrayOff.swift` and the guidance in `CONTRIBUTING.md`:
- Organize longer files with `// MARK: - ...` headings. Common section names are `Properties`, `Published Properties`, `Computed Properties`, `Initialization`, `Body`, `Public Methods`, `Private Methods`, `Persistence`, `Helpers`, and `Preview`.
- Keep SwiftUI modifier chains vertically aligned and one modifier per line, as in `Retainer Tracker/Views/HomeView.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Use `#Preview` blocks at the bottom of SwiftUI files. When a preview needs SwiftData, create an in-memory `ModelContainer` as in `Retainer Tracker/Views/HomeView.swift`.
- Linting tool: Not detected.
- Follow the Swift API Design Guidelines as required by `CONTRIBUTING.md`.
- Keep public and app-facing internal types, methods, and properties documented with `///` comments. This pattern is used in `Retainer Tracker/Models/Session.swift`, `Retainer Tracker/Services/TimerEngine.swift`, and `Retainer Tracker/ViewModels/TimerViewModel.swift`.
## Import Organization
- Views import SwiftUI first, then supporting frameworks: `Retainer Tracker/Views/StatsView.swift` imports `SwiftUI`, `Charts`, then `SwiftData`.
- Models import data foundations first: `Retainer Tracker/Models/Session.swift` imports `Foundation` and `SwiftData`.
- Coordinators import the frameworks they bridge: `Retainer Tracker/ViewModels/TimerViewModel.swift` imports `SwiftUI`, `Combine`, `SwiftData`, and `WidgetKit`.
- Widget files import `WidgetKit`, `SwiftUI`, and `ActivityKit` where needed: `RetainerWidget/RetainerActivityWidget.swift`.
- Not applicable. The project uses app target membership and direct Swift module visibility, not custom path aliases.
- Package sources are mapped by `Package.swift` to the `Retainer Tracker/` path. Do not add import aliases or generated barrel files.
## Error Handling
- Use `do`/`catch` around platform setup or async API calls that produce a user-visible capability result: `ModelContainer` initialization in `Retainer Tracker/App/TrayOff.swift`, notification authorization in `Retainer Tracker/Services/NotificationService.swift`, and Live Activity creation in `Retainer Tracker/Services/LiveActivityManager.swift`.
- Use early `guard` exits for invalid no-op operations: `scheduleReminder(minutes:)` in `Retainer Tracker/Services/NotificationService.swift`, `update(...)` and `stop()` in `Retainer Tracker/Services/LiveActivityManager.swift`, `loadState()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use optional `try?` for best-effort persistence and timer sleeps where failure is intentionally non-fatal: `JSONEncoder().encode` and `JSONDecoder().decode` in `Retainer Tracker/Services/PersistenceService.swift`, `Task.sleep` in `Retainer Tracker/Services/TimerEngine.swift` and `Retainer Tracker/Services/ReminderManager.swift`.
- Keep persistence failures localized. `SessionManager.loadSessions()` catches SwiftData fetch errors and resets `sessions` to an empty array in `Retainer Tracker/Services/SessionManager.swift`.
- Reserve `fatalError` for unrecoverable app boot failures. The only app startup fatal path is `ModelContainer` creation in `Retainer Tracker/App/TrayOff.swift`.
- Keep UI methods non-throwing. Convert errors into state, `nil`, `false`, or no-op behavior inside services before they reach SwiftUI views.
## Logging
- Prefix console output with the component name. `Retainer Tracker/Services/NotificationService.swift` logs `[NotificationService] Failed to schedule notification: ...`.
- No structured logging framework is configured. Do not introduce ad hoc verbose logs in SwiftUI views.
- Prefer returning a value or updating observable state over printing when the caller can react, as in `requestPermissions() async -> Bool` in `Retainer Tracker/Services/NotificationService.swift`.
## Comments
- Document every type and service method that forms part of the app architecture. `CONTRIBUTING.md` explicitly requires documentation comments for public types, methods, and properties, and the source applies this broadly to internal app types.
- Use `// MARK: -` comments to divide files into predictable sections. Keep these section names consistent with nearby files.
- Use short inline comments only for non-obvious platform behavior or algorithm intent, such as reconnecting Live Activities in `Retainer Tracker/Services/LiveActivityManager.swift` or restoring running timer state in `Retainer Tracker/Services/TimerEngine.swift`.
- Avoid comments that restate a single line of code. Prefer extracting a computed property or helper method when the explanation grows.
- Not applicable. Use Swift documentation comments (`///`) with `- Parameter`, `- Parameters`, `- Returns`, and `- Note` fields where useful.
- Match the style in `Retainer Tracker/Models/Session.swift` and `Retainer Tracker/Services/PersistenceService.swift`.
## Function Design
- `TimeFormatter.format(_:) -> String` in `Retainer Tracker/Utils/TimeFormatter.swift`
- `TimerViewModel.getStatistics() -> (totalTime: Double, averageTime: Double, sessionCount: Int)` in `Retainer Tracker/ViewModels/TimerViewModel.swift`
- `TimerViewModel.getStreakStats() -> StreakStats` in `Retainer Tracker/ViewModels/TimerViewModel.swift`
- App-level ownership starts in `Retainer Tracker/App/TrayOff.swift` with `@StateObject private var viewModel`.
- Root view access uses `@EnvironmentObject` in `Retainer Tracker/Views/ContentView.swift`.
- Child views receive `@ObservedObject var viewModel` when they need to observe app state, as in `Retainer Tracker/Views/HomeView.swift` and `Retainer Tracker/Views/StatsView.swift`.
- Local presentation and editing state uses `@State`, such as `showSettingsSheet`, `showTimePicker`, `selectedSession`, and `isEditing`.
- UserDefaults-backed UI preferences use `@AppStorage`, as in `Retainer Tracker/Views/ContentView.swift`, or `@Published` with `didSet`, as in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `Retainer Tracker/Services/ReminderManager.swift`.
- Use `Task<Void, Never>?` properties for cancellable background loops and cancel the existing task before starting a new one, matching `Retainer Tracker/Services/TimerEngine.swift` and `Retainer Tracker/Services/ReminderManager.swift`.
- Move observable updates back to the main actor from background tasks with `await MainActor.run`.
- Mark UI-facing coordinators that touch SwiftData or ActivityKit as `@MainActor`, as in `TimerViewModel`, `SessionManager`, and `LiveActivityManager`.
## Module Design
- Define protocol interfaces before concrete service implementations when the service coordinates state or persistence: `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/ReminderManager.swift`, `Retainer Tracker/Services/PersistenceService.swift`.
- Keep platform singletons narrow and explicit. Existing singletons are `NotificationService.shared` in `Retainer Tracker/Services/NotificationService.swift` and `LiveActivityManager.shared` in `Retainer Tracker/Services/LiveActivityManager.swift`.
- Keep business orchestration in `TimerViewModel`, not in SwiftUI views. Views call methods such as `toggleTimer()`, `deleteSession(_:)`, and `updateSession(_:)`.
- Reuse `AppConfig` constants for dimensions, spacing, corner radii, and animation timings instead of duplicating literals in new reusable components.
- Use SF Symbols through `Image(systemName:)`, as in `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, and `RetainerWidget/RetainerActivityWidget.swift`.
- Keep previews close to the view they exercise and use in-memory SwiftData containers when a view needs `Session` or `TimerViewModel`.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## System Overview
```text
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
- Keep screen state and commands in `Retainer Tracker/ViewModels/TimerViewModel.swift`; views call methods and render `@Published` state.
- Keep platform APIs behind services in `Retainer Tracker/Services/` so SwiftUI screens do not talk directly to SwiftData, ActivityKit, WidgetKit, or `UNUserNotificationCenter`.
- Treat `RetainerWidget/` as an extension boundary. It does not use `TimerViewModel`; it reads the App Group `TimerState` payload and ActivityKit attributes.
- Keep cross-target contracts simple and codable. `RetainerActivityAttributes` lives in `Retainer Tracker/Models/RetainerActivityAttributes.swift` and is shared with the widget target through Xcode target membership.
## Layers
- Purpose: Start the app scene, initialize persistence, and install environment dependencies.
- Location: `Retainer Tracker/App/TrayOff.swift`
- Contains: `TrayOffApp`, `ModelContainer`, scene phase routing.
- Depends on: `SwiftUI`, `SwiftData`, `Session`, `TimerViewModel`.
- Used by: iOS app process entry point from `TrayOff.xcodeproj/project.pbxproj`.
- Purpose: Render screens and translate user gestures into view-model commands.
- Location: `Retainer Tracker/Views/`
- Contains: `ContentView`, `HomeView`, `StatsView`, `SettingsView`, `OnboardingView`, and reusable components under `Retainer Tracker/Views/Components/`.
- Depends on: `TimerViewModel`, `Session`, `TimeFormatter`, `AppConfig`, SwiftUI, Swift Charts.
- Used by: `TrayOffApp` and SwiftUI previews inside individual view files.
- Purpose: Coordinate all timer use cases, bind service output to UI state, compute statistics, and persist timer snapshots.
- Location: `Retainer Tracker/ViewModels/TimerViewModel.swift`
- Contains: `TimerViewModel`, published app state, public commands, Combine subscriptions, midnight rollover logic.
- Depends on: `TimerEngine`, `SessionManager`, `ReminderManager`, `TimerPersistenceServiceProtocol`, `LiveActivityManager`, `WidgetCenter`, `ModelContext`.
- Used by: `ContentView`, `HomeView`, `StatsView`, `SettingsView`, and timer components.
- Purpose: Isolate platform effects and long-running timer/reminder tasks.
- Location: `Retainer Tracker/Services/`
- Contains: `TimerEngine`, `SessionManager`, `ReminderManager`, `NotificationService`, `LiveActivityManager`, `TimerPersistenceService`.
- Depends on: `SwiftData`, `Combine`, `ActivityKit`, `UserNotifications`, `WidgetKit` indirectly through the view model, and App Group `UserDefaults`.
- Used by: `TimerViewModel` and `ContentView` for permission request.
- Purpose: Define persisted and shared domain records.
- Location: `Retainer Tracker/Models/`
- Contains: `Session` SwiftData model and `RetainerActivityAttributes` ActivityKit contract.
- Depends on: `SwiftData`, `ActivityKit`, `Foundation`.
- Used by: app services, SwiftData container setup, and widget ActivityKit UI.
- Purpose: Render WidgetKit home-screen widget and ActivityKit Dynamic Island/Lock Screen surfaces.
- Location: `RetainerWidget/`
- Contains: `RetainerWidgetBundle`, `RetainerWidget`, `RetainerActivityWidget`, widget-only display helpers.
- Depends on: `WidgetKit`, `SwiftUI`, `ActivityKit`, App Group `UserDefaults`, and shared `RetainerActivityAttributes`.
- Used by: `RetainerWidgetExtension` target configured in `TrayOff.xcodeproj/project.pbxproj`.
- Purpose: Store constants, formatting helpers, Info.plist files, entitlements, asset catalogs, and app icon assets.
- Location: `Retainer Tracker/Utils/`, `Retainer-Tracker-Info.plist`, `Retainer Tracker/Retainer Tracker.entitlements`, `RetainerWidget/Info.plist`, `RetainerWidgetExtension.entitlements`, `Retainer Tracker/Assets.xcassets/`, `RetainerWidget/Assets.xcassets/`, `TrayOff.icon/`
- Contains: `AppConfig`, `TimeFormatter`, bundle metadata, App Group entitlements, launch image, accent colors, widget colors, and app icon layers.
- Depends on: Xcode build settings in `TrayOff.xcodeproj/project.pbxproj`.
- Used by: app target, widget target, and SwiftUI views.
## Data Flow
### Primary App Launch Path
### Timer Start/Stop Path
### Timer Tick and UI Update Path
### Session and Statistics Path
### Widget and Live Activity Path
- Use `TimerViewModel` as the single screen-facing state owner for timer state, sessions, reminder countdown, goal, danger, and goal-status visibility in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use SwiftData for historical sessions through `Session` in `Retainer Tracker/Models/Session.swift`.
- Use App Group `UserDefaults` for widget-readable timer snapshots through `TimerPersistenceService` in `Retainer Tracker/Services/PersistenceService.swift`.
- Use `@AppStorage("hasSeenOnboarding")` only for onboarding presentation state in `Retainer Tracker/Views/ContentView.swift`.
- Use `UserDefaults.standard` only for simple app preferences such as `selectedReminder` in `Retainer Tracker/Services/ReminderManager.swift` and `showGoalStatus` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
## Key Abstractions
- Purpose: Application use-case facade for screens.
- Examples: `Retainer Tracker/ViewModels/TimerViewModel.swift`, `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`
- Pattern: `@MainActor ObservableObject` with constructor-injected services and Combine bindings.
- Purpose: Persisted retainer-off interval.
- Examples: `Retainer Tracker/Models/Session.swift`, `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Views/StatsView.swift`
- Pattern: SwiftData `@Model` with computed `duration`.
- Purpose: Codable snapshot of active timer state for launch restore and widget sharing.
- Examples: `Retainer Tracker/Services/PersistenceService.swift`, `RetainerWidget/RetainerWidget.swift`
- Pattern: JSON-encoded App Group `UserDefaults` payload under key `timerState`.
- Purpose: Shared ActivityKit contract for Live Activity state.
- Examples: `Retainer Tracker/Models/RetainerActivityAttributes.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`, `RetainerWidget/RetainerActivityWidget.swift`
- Pattern: `ActivityAttributes` with nested codable/hashable `ContentState`.
- Purpose: Define testable contracts for timer, session, reminder, and persistence behavior.
- Examples: `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Services/ReminderManager.swift`, `Retainer Tracker/Services/PersistenceService.swift`
- Pattern: Protocol plus concrete class for service implementation; `TimerViewModel` constructor injects timer/reminder/persistence services.
- Purpose: Immutable display record for home-screen widget rendering.
- Examples: `RetainerWidget/RetainerWidget.swift`
- Pattern: `TimelineProvider` loads App Group state and maps it into `SimpleEntry`.
## Entry Points
- Location: `Retainer Tracker/App/TrayOff.swift`
- Triggers: App launch through `TrayOff` application target in `TrayOff.xcodeproj/project.pbxproj`.
- Responsibilities: Bootstrap SwiftData, create `TimerViewModel`, install environment state, route scene phase events.
- Location: `Retainer Tracker/Views/ContentView.swift`
- Triggers: `WindowGroup` body from `TrayOffApp`.
- Responsibilities: Tabs, onboarding presentation, notification permission request.
- Location: `Retainer Tracker/Views/Components/TimerButtonView.swift`
- Triggers: Tap and long-press gestures from the Home screen.
- Responsibilities: Start/stop timer action and reminder duration picker.
- Location: `RetainerWidget/RetainerWidgetBundle.swift`
- Triggers: WidgetKit loads `RetainerWidgetExtension`.
- Responsibilities: Register the static widget and Live Activity widget.
- Location: `RetainerWidget/RetainerWidget.swift`
- Triggers: WidgetKit timeline snapshot or refresh.
- Responsibilities: Decode shared `TimerState` and render `RetainerWidgetEntryView`.
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
### Deep Component Coupling To `TimerViewModel`
## Error Handling
- `TrayOffApp.init()` uses `fatalError` if `ModelContainer` cannot be created in `Retainer Tracker/App/TrayOff.swift`.
- `SessionManager` uses `try?` or fallback empty sessions for SwiftData failures in `Retainer Tracker/Services/SessionManager.swift`.
- `TimerPersistenceService` returns `nil` when the App Group payload cannot decode in `Retainer Tracker/Services/PersistenceService.swift`.
- `NotificationService.requestPermissions()` returns `false` on authorization errors in `Retainer Tracker/Services/NotificationService.swift`.
- `LiveActivityManager.start()` catches ActivityKit request errors without surfacing UI state in `Retainer Tracker/Services/LiveActivityManager.swift`.
- `NotificationService.scheduleReminder(minutes:)` logs scheduling failures with `print` in `Retainer Tracker/Services/NotificationService.swift`.
## Cross-Cutting Concerns
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
