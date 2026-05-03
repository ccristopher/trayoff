---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: arch
---
# Codebase Structure

**Analysis Date:** 2026-05-02

## Directory Layout

```text
trayoff/
├── Package.swift                         # SwiftPM library manifest for `Retainer Tracker/`
├── README.md                             # User-facing overview and architecture summary
├── CONTRIBUTING.md                       # Contribution guide
├── LICENSE                               # MIT license
├── .gitignore                            # Swift/Xcode ignore rules
├── .swiftpm/                             # SwiftPM/Xcode workspace metadata
├── .planning/codebase/                   # Generated GSD codebase maps
├── Retainer-Tracker-Info.plist           # Main app Info.plist
├── RetainerWidgetExtension.entitlements  # Widget extension App Group entitlement
├── Retainer Tracker/
│   ├── App/                              # SwiftUI app entry point
│   ├── Models/                           # SwiftData and ActivityKit domain models
│   ├── Services/                         # Timer, persistence, notification, activity services
│   ├── ViewModels/                       # Screen-facing app state coordinator
│   ├── Views/                            # SwiftUI screens
│   │   └── Components/                   # Reusable SwiftUI pieces
│   ├── Utils/                            # Constants and formatting helpers
│   ├── Assets.xcassets/                  # Main app asset catalog
│   ├── Preview Content/                  # SwiftUI preview assets
│   └── Retainer Tracker.entitlements     # Main app App Group entitlement
├── RetainerWidget/
│   ├── RetainerWidgetBundle.swift        # Widget extension entry point
│   ├── RetainerWidget.swift              # Home-screen widget
│   ├── RetainerActivityWidget.swift      # Live Activity widget UI
│   ├── Info.plist                        # Widget extension Info.plist
│   └── Assets.xcassets/                  # Widget asset catalog
├── TrayOff.icon/                         # Icon Composer source assets
└── TrayOff.xcodeproj/                    # Xcode project, schemes, workspace metadata
```

## Directory Purposes

**`Retainer Tracker/App/`:**
- Purpose: Own the SwiftUI application entry point.
- Contains: App lifecycle, SwiftData container setup, environment injection, scene phase routing.
- Key files: `Retainer Tracker/App/TrayOff.swift`

**`Retainer Tracker/Models/`:**
- Purpose: Define domain records and platform contracts that are not UI-specific.
- Contains: SwiftData models and ActivityKit attributes.
- Key files: `Retainer Tracker/Models/Session.swift`, `Retainer Tracker/Models/RetainerActivityAttributes.swift`

**`Retainer Tracker/Services/`:**
- Purpose: Encapsulate platform side effects, persistence, timer loops, reminders, and session CRUD.
- Contains: Service classes, service protocols, App Group persistence payloads.
- Key files: `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/SessionManager.swift`, `Retainer Tracker/Services/ReminderManager.swift`, `Retainer Tracker/Services/NotificationService.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`, `Retainer Tracker/Services/PersistenceService.swift`

**`Retainer Tracker/ViewModels/`:**
- Purpose: Hold screen-facing state and coordinate service calls.
- Contains: Main `ObservableObject` state coordinator.
- Key files: `Retainer Tracker/ViewModels/TimerViewModel.swift`

**`Retainer Tracker/Views/`:**
- Purpose: Hold SwiftUI screens and screen-level compositions.
- Contains: Root tabs, Home, Stats, Settings, onboarding, and sheet views.
- Key files: `Retainer Tracker/Views/ContentView.swift`, `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, `Retainer Tracker/Views/SettingsView.swift`, `Retainer Tracker/Views/OnboardingView.swift`

**`Retainer Tracker/Views/Components/`:**
- Purpose: Hold reusable UI components used by app screens.
- Contains: Timer ring, button, status, goal status, background, and activity ring views.
- Key files: `Retainer Tracker/Views/Components/TimerRingView.swift`, `Retainer Tracker/Views/Components/TimerButtonView.swift`, `Retainer Tracker/Views/Components/ActivityRing.swift`, `Retainer Tracker/Views/Components/StatusView.swift`, `Retainer Tracker/Views/Components/GoalStatusView.swift`, `Retainer Tracker/Views/Components/BackgroundGradientView.swift`

**`Retainer Tracker/Utils/`:**
- Purpose: Hold cross-cutting constants and pure formatting helpers.
- Contains: Static app configuration and duration formatting.
- Key files: `Retainer Tracker/Utils/AppConfig.swift`, `Retainer Tracker/Utils/TimeFormatter.swift`

**`Retainer Tracker/Assets.xcassets/`:**
- Purpose: Hold main app asset catalog resources.
- Contains: Accent color and launch-screen logo image set.
- Key files: `Retainer Tracker/Assets.xcassets/Contents.json`, `Retainer Tracker/Assets.xcassets/AccentColor.colorset/Contents.json`, `Retainer Tracker/Assets.xcassets/LaunchScreenLogo.imageset/Contents.json`

**`Retainer Tracker/Preview Content/`:**
- Purpose: Hold SwiftUI preview-only assets.
- Contains: Preview asset catalog.
- Key files: `Retainer Tracker/Preview Content/Preview Assets.xcassets/Contents.json`

**`RetainerWidget/`:**
- Purpose: Hold WidgetKit extension implementation.
- Contains: Widget bundle entry point, static home widget, Live Activity widget, widget Info.plist, and widget assets.
- Key files: `RetainerWidget/RetainerWidgetBundle.swift`, `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerActivityWidget.swift`, `RetainerWidget/Info.plist`

**`RetainerWidget/Assets.xcassets/`:**
- Purpose: Hold widget extension asset resources.
- Contains: Accent color, widget background color, and widget app icon catalog.
- Key files: `RetainerWidget/Assets.xcassets/Contents.json`, `RetainerWidget/Assets.xcassets/WidgetBackground.colorset/Contents.json`, `RetainerWidget/Assets.xcassets/AppIcon.appiconset/Contents.json`

**`TrayOff.xcodeproj/`:**
- Purpose: Define build targets, schemes, target membership, build settings, and embedded extension setup.
- Contains: Project file, shared schemes, and workspace metadata.
- Key files: `TrayOff.xcodeproj/project.pbxproj`, `TrayOff.xcodeproj/xcshareddata/xcschemes/Retainer Tracker.xcscheme`, `TrayOff.xcodeproj/xcshareddata/xcschemes/RetainerWidgetExtension.xcscheme`, `TrayOff.xcodeproj/project.xcworkspace/contents.xcworkspacedata`

**`TrayOff.icon/`:**
- Purpose: Hold Icon Composer source assets used by Xcode resources.
- Contains: Layer images and icon metadata.
- Key files: `TrayOff.icon/icon.json`, `TrayOff.icon/Assets/1 – Layer.png`, `TrayOff.icon/Assets/2 – Layer.png`

**`.planning/codebase/`:**
- Purpose: Hold generated codebase mapping documents for GSD planning and execution.
- Contains: Architecture and structure maps for this focus area.
- Key files: `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`

## Key File Locations

**Entry Points:**
- `Retainer Tracker/App/TrayOff.swift`: Main iOS app `@main` entry point.
- `Retainer Tracker/Views/ContentView.swift`: Root SwiftUI tab navigation and onboarding presentation.
- `RetainerWidget/RetainerWidgetBundle.swift`: Widget extension `@main` entry point.
- `RetainerWidget/RetainerWidget.swift`: Home-screen widget timeline provider and widget view.
- `RetainerWidget/RetainerActivityWidget.swift`: ActivityKit Lock Screen and Dynamic Island widget UI.

**Configuration:**
- `TrayOff.xcodeproj/project.pbxproj`: Xcode targets, file-system synchronized groups, build phases, deployment targets, bundle IDs, entitlements, and embedded extension dependency.
- `TrayOff.xcodeproj/xcshareddata/xcschemes/Retainer Tracker.xcscheme`: Shared app run/build scheme.
- `TrayOff.xcodeproj/xcshareddata/xcschemes/RetainerWidgetExtension.xcscheme`: Shared widget extension run/build scheme.
- `Package.swift`: SwiftPM library manifest pointing target `TrayOff` at `Retainer Tracker/`.
- `Retainer-Tracker-Info.plist`: Main app Info.plist metadata and launch screen settings.
- `RetainerWidget/Info.plist`: Widget extension Info.plist with `com.apple.widgetkit-extension`.
- `Retainer Tracker/Retainer Tracker.entitlements`: Main app App Group entitlement.
- `RetainerWidgetExtension.entitlements`: Widget extension App Group entitlement.

**Core Logic:**
- `Retainer Tracker/ViewModels/TimerViewModel.swift`: App use-case coordinator and state publisher.
- `Retainer Tracker/Services/TimerEngine.swift`: Elapsed-time engine and progress publisher.
- `Retainer Tracker/Services/SessionManager.swift`: SwiftData session CRUD and fetch logic.
- `Retainer Tracker/Services/PersistenceService.swift`: App Group timer-state serialization.
- `Retainer Tracker/Services/ReminderManager.swift`: Reminder countdown state.
- `Retainer Tracker/Services/NotificationService.swift`: Local notification scheduling.
- `Retainer Tracker/Services/LiveActivityManager.swift`: ActivityKit lifecycle management.
- `Retainer Tracker/Models/Session.swift`: SwiftData session model.
- `Retainer Tracker/Models/RetainerActivityAttributes.swift`: ActivityKit shared attributes.

**UI Logic:**
- `Retainer Tracker/Views/HomeView.swift`: Timer screen composition and settings sheet trigger.
- `Retainer Tracker/Views/StatsView.swift`: Statistics, history chart, and session editing.
- `Retainer Tracker/Views/SettingsView.swift`: Goal, danger, reminder, and status settings.
- `Retainer Tracker/Views/OnboardingView.swift`: First-launch walkthrough.
- `Retainer Tracker/Views/Components/TimerButtonView.swift`: Main timer button and reminder picker.
- `Retainer Tracker/Views/Components/TimerRingView.swift`: Ring/button composition.
- `Retainer Tracker/Views/Components/ActivityRing.swift`: Ring drawing and threshold trim logic.

**Utilities:**
- `Retainer Tracker/Utils/AppConfig.swift`: Timer defaults, persistence keys, UI sizing, and animation timing constants.
- `Retainer Tracker/Utils/TimeFormatter.swift`: App duration formatting.
- `RetainerWidget/RetainerWidget.swift`: Widget-local `HomeWidgetTimeFormatter`.
- `RetainerWidget/RetainerActivityWidget.swift`: Widget-local `TimeFormatter`.

**Assets:**
- `Retainer Tracker/Assets.xcassets/`: Main app colors and launch logo.
- `RetainerWidget/Assets.xcassets/`: Widget colors and icon catalog.
- `TrayOff.icon/`: Icon Composer source.

**Testing:**
- Not detected. No `*Tests/`, `*.test.swift`, `*.spec.swift`, `XCTest`, or Swift Testing files are present.
- SwiftUI preview setups exist inside view files such as `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, and `Retainer Tracker/Views/Components/TimerRingView.swift`.

## Naming Conventions

**Files:**
- Use one Swift file per primary type: `Retainer Tracker/ViewModels/TimerViewModel.swift`, `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Models/Session.swift`.
- Use `*View.swift` for SwiftUI screens and components: `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/Components/TimerButtonView.swift`.
- Use `*Service.swift`, `*Manager.swift`, or `*Engine.swift` for side-effect and orchestration services: `Retainer Tracker/Services/NotificationService.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`, `Retainer Tracker/Services/TimerEngine.swift`.
- Use `*Attributes.swift` for ActivityKit contracts: `Retainer Tracker/Models/RetainerActivityAttributes.swift`.
- Use target-specific plist and entitlement names at the root or target folder: `Retainer-Tracker-Info.plist`, `RetainerWidget/Info.plist`, `RetainerWidgetExtension.entitlements`, `Retainer Tracker/Retainer Tracker.entitlements`.

**Directories:**
- Use layer-oriented directories under `Retainer Tracker/`: `App/`, `Models/`, `Services/`, `ViewModels/`, `Views/`, `Utils/`.
- Use `Retainer Tracker/Views/Components/` for reusable view pieces instead of placing them beside screens.
- Use one top-level directory per Xcode target source root: `Retainer Tracker/` for the app target and `RetainerWidget/` for the widget extension target.
- Keep Xcode-managed project files under `TrayOff.xcodeproj/`.

**Types:**
- Use UpperCamelCase for Swift types: `TimerViewModel`, `SessionManager`, `RetainerWidgetEntryView`.
- Use protocol names with `Protocol` suffix where service contracts exist: `TimerEngineProtocol`, `SessionManagerProtocol`, `ReminderManagerProtocol`, `TimerPersistenceServiceProtocol`.
- Use nested enum namespaces for constants in `Retainer Tracker/Utils/AppConfig.swift`: `AppConfig.Timer`, `AppConfig.Persistence`, `AppConfig.UI`, `AppConfig.Animation`.

## Where to Add New Code

**New SwiftUI Screen:**
- Primary code: Add `Retainer Tracker/Views/<Feature>View.swift`.
- Navigation/tab integration: Edit `Retainer Tracker/Views/ContentView.swift` for a new tab or route from `Retainer Tracker/Views/HomeView.swift` / `Retainer Tracker/Views/StatsView.swift` for modal or nested navigation.
- State access: Consume `TimerViewModel` from the screen boundary; pass narrow props and callbacks into components under `Retainer Tracker/Views/Components/`.

**New Reusable Component:**
- Implementation: Add `Retainer Tracker/Views/Components/<ComponentName>View.swift`.
- Configuration: Prefer inputs, bindings, and callbacks over directly observing `TimerViewModel`.
- Constants: Add reusable sizing/timing values to `Retainer Tracker/Utils/AppConfig.swift`.

**New Timer or Session Use Case:**
- Orchestration: Add public methods and computed state to `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Service behavior: Add focused implementation to `Retainer Tracker/Services/`.
- Persistence: Route session history through `Retainer Tracker/Services/SessionManager.swift`; route active timer snapshots through `Retainer Tracker/Services/PersistenceService.swift`.

**New Persisted SwiftData Model:**
- Model: Add `Retainer Tracker/Models/<ModelName>.swift`.
- Container: Add the model to `Schema([...])` in `Retainer Tracker/App/TrayOff.swift`.
- Manager: Add or extend a service under `Retainer Tracker/Services/` to own fetch/save/delete operations.
- UI: Expose data through `Retainer Tracker/ViewModels/TimerViewModel.swift` rather than fetching directly in screen views.

**New App Preference:**
- Constants: Add a key to `AppConfig.Persistence` in `Retainer Tracker/Utils/AppConfig.swift`.
- Simple UI-only state: Use `@AppStorage` in the owning view, following `Retainer Tracker/Views/ContentView.swift`.
- App-wide behavior state: Route through `TimerViewModel` and a service, following `showGoalStatus` in `Retainer Tracker/ViewModels/TimerViewModel.swift` and `selectedReminder` in `Retainer Tracker/Services/ReminderManager.swift`.

**New Notification Behavior:**
- Scheduling/cancellation: Extend `Retainer Tracker/Services/NotificationService.swift`.
- Reminder countdown orchestration: Extend `Retainer Tracker/Services/ReminderManager.swift`.
- UI state exposure: Publish state through `Retainer Tracker/ViewModels/TimerViewModel.swift`.

**New Live Activity Feature:**
- Shared state contract: Extend `Retainer Tracker/Models/RetainerActivityAttributes.swift`.
- Activity lifecycle: Extend `Retainer Tracker/Services/LiveActivityManager.swift`.
- Activity UI: Extend `RetainerWidget/RetainerActivityWidget.swift`.
- Target membership: Keep ActivityKit contracts extension-safe and included in the widget extension target through `TrayOff.xcodeproj/project.pbxproj`.

**New Home-Screen Widget Feature:**
- Widget UI/provider: Add code under `RetainerWidget/`.
- Shared snapshot data: Add fields to the App Group payload in `Retainer Tracker/Services/PersistenceService.swift` and keep the widget decoder in `RetainerWidget/RetainerWidget.swift` synchronized.
- Timeline refresh: Trigger widget updates from `Retainer Tracker/ViewModels/TimerViewModel.swift` with `WidgetCenter.shared.reloadAllTimelines()`.

**New Shared Cross-Target Model:**
- Implementation: Prefer `Retainer Tracker/Models/<SharedName>.swift` when the model belongs to app domain concepts.
- Target setup: Ensure the file belongs to both the app target and widget extension target in `TrayOff.xcodeproj/project.pbxproj`.
- Restrictions: Keep shared files free of app-only dependencies such as `SwiftData` when the widget extension needs them.

**New Asset:**
- Main app asset: Add to `Retainer Tracker/Assets.xcassets/`.
- Widget asset: Add to `RetainerWidget/Assets.xcassets/`.
- App icon layer: Add to `TrayOff.icon/` only for icon-composer assets referenced by the Xcode project.

**New Tests:**
- Test target: Add an XCTest or Swift Testing target in `TrayOff.xcodeproj/project.pbxproj`.
- Unit tests: Place timer, reminder, persistence, and view-model tests in a new test directory such as `TrayOffTests/`.
- Testability: Use existing constructor injection in `Retainer Tracker/ViewModels/TimerViewModel.swift` for `TimerEngine`, `ReminderManager`, and `TimerPersistenceServiceProtocol`.

## Special Directories

**`.planning/codebase/`:**
- Purpose: Generated architecture, structure, stack, testing, convention, integration, and concern maps for GSD workflows.
- Generated: Yes.
- Committed: Yes, when orchestrator chooses to commit planning artifacts.

**`.swiftpm/`:**
- Purpose: SwiftPM/Xcode package workspace metadata.
- Generated: Yes.
- Committed: Yes, `git ls-files` includes `.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata`.

**`TrayOff.xcodeproj/`:**
- Purpose: Xcode project source of truth for app and widget targets.
- Generated: Partially; Xcode edits `TrayOff.xcodeproj/project.pbxproj` and scheme files.
- Committed: Yes.

**`Retainer Tracker/Preview Content/`:**
- Purpose: SwiftUI preview asset catalog.
- Generated: No.
- Committed: Yes.

**`Retainer Tracker/Assets.xcassets/`:**
- Purpose: Main app runtime assets.
- Generated: No.
- Committed: Yes.

**`RetainerWidget/Assets.xcassets/`:**
- Purpose: Widget extension runtime assets.
- Generated: No.
- Committed: Yes.

**`TrayOff.icon/`:**
- Purpose: Icon Composer source directory used as an Xcode resource.
- Generated: No.
- Committed: Yes.

---

*Structure analysis: 2026-05-02*
