---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: concerns
---
# Codebase Concerns

**Analysis Date:** 2026-05-02

## Tech Debt

**Timer state schema and constants are duplicated across targets:**
- Issue: `TimerState`, the `timerState` key, and the `group.com.TrayOff.shared` App Group string are defined separately in the app and widget.
- Files: `Retainer Tracker/Services/PersistenceService.swift:15`, `RetainerWidget/RetainerWidget.swift:15`, `Retainer Tracker/Services/PersistenceService.swift:65`, `RetainerWidget/RetainerWidget.swift:30`, `Retainer Tracker/Retainer Tracker.entitlements:7`, `RetainerWidgetExtension.entitlements:7`
- Impact: A timer-state field, key, or App Group change can compile in one target while silently breaking widget reads or migration in the other target.
- Fix approach: Move the shared Codable state and persistence constants into a shared source file included by both targets, or create a small shared package/module. Keep entitlements and source constants documented together when changing the App Group.

**`TimerViewModel` owns too many responsibilities:**
- Issue: One 412-line view model coordinates timer state, sessions, reminders, persistence, widget reloads, live activities, daily stats, streaks, and midnight rollover.
- Files: `Retainer Tracker/ViewModels/TimerViewModel.swift`
- Impact: Timer changes can regress statistics, widget sync, reminder state, or Live Activities because the orchestration logic is coupled in one class.
- Fix approach: Extract `StatsCalculator`, `TimerStateCoordinator`, and `LiveActivitySynchronizer` style collaborators. Keep `TimerViewModel` focused on UI-facing published state and command dispatch.

**Settings keys and reminder options are not centralized:**
- Issue: `selectedReminder` and `showGoalStatus` use literal `UserDefaults` keys, while `AppConfig.Persistence` defines unused keys. Reminder options differ between Settings and the long-press wheel.
- Files: `Retainer Tracker/Services/ReminderManager.swift:45`, `Retainer Tracker/ViewModels/TimerViewModel.swift:50`, `Retainer Tracker/Utils/AppConfig.swift:33`, `Retainer Tracker/Views/SettingsView.swift:53`, `Retainer Tracker/Views/Components/TimerButtonView.swift:57`
- Impact: Settings can drift from the home control. A reminder value persisted from Settings may not exist in the wheel picker.
- Fix approach: Put keys and reminder-duration options in `Retainer Tracker/Utils/AppConfig.swift` and bind both `SettingsView` and `TimerButtonView` to the same list.

**Swift Package manifest is stale as a build surface:**
- Issue: `Package.swift` declares Swift tools 5.3 and iOS 14 while the source uses SwiftData, `#Preview`, ActivityKit, WidgetKit, and iOS 26-only APIs. `swift build --build-path /tmp/trayoff-swift-build` fails with availability and macro errors, and warns that `Retainer Tracker/Retainer Tracker.entitlements` is unhandled.
- Files: `Package.swift:1`, `Package.swift:7`, `Package.swift:16`, `Retainer Tracker/Models/Session.swift:16`, `Retainer Tracker/App/TrayOff.swift:16`
- Impact: Contributors can reasonably try `swift build` and get a non-working build path unrelated to the Xcode project. Automation built around SwiftPM will fail.
- Fix approach: Remove `Package.swift` if the app is Xcode-project only, or update it to a supported toolchain/platform/resource layout and isolate app-extension code that SwiftPM cannot build directly.

**Errors are commonly swallowed:**
- Issue: Persistence, SwiftData saves/fetches, notifications, and Live Activity requests use `try?`, empty `catch`, or console-only error reporting.
- Files: `Retainer Tracker/Services/SessionManager.swift:87`, `Retainer Tracker/Services/SessionManager.swift:96`, `Retainer Tracker/Services/SessionManager.swift:110`, `Retainer Tracker/Services/SessionManager.swift:117`, `Retainer Tracker/Services/PersistenceService.swift:83`, `Retainer Tracker/Services/PersistenceService.swift:90`, `Retainer Tracker/Services/LiveActivityManager.swift:62`, `Retainer Tracker/Services/NotificationService.swift:34`, `Retainer Tracker/Services/NotificationService.swift:70`
- Impact: Data loss, migration failure, notification failure, and Live Activity failure are not actionable in UI or telemetry.
- Fix approach: Return typed results or throw from service methods, handle failures in `TimerViewModel`, and log with `Logger`/OSLog using privacy annotations.

## Known Bugs

**Custom goal and danger settings are not restored after launch:**
- Symptoms: `goal` and `danger` start from defaults every `TimerViewModel` init. `TimerState` includes optional `goal` and `danger`, but `loadState()` never applies them.
- Files: `Retainer Tracker/ViewModels/TimerViewModel.swift:44`, `Retainer Tracker/ViewModels/TimerViewModel.swift:47`, `Retainer Tracker/ViewModels/TimerViewModel.swift:341`, `Retainer Tracker/ViewModels/TimerViewModel.swift:366`, `Retainer Tracker/Services/PersistenceService.swift:34`
- Trigger: Change goal or danger in `SettingsView`, terminate and relaunch the app.
- Workaround: None in UI. Fix by loading `state.goal` and `state.danger`, persisting slider changes immediately, and reloading widget/Live Activity state after settings changes.

**Goal and danger slider changes are not saved immediately:**
- Symptoms: Moving sliders changes in-memory values, but `saveState()` only runs from timer lifecycle, session recalculation, reset, or app lifecycle paths.
- Files: `Retainer Tracker/Views/SettingsView.swift:32`, `Retainer Tracker/Views/SettingsView.swift:42`, `Retainer Tracker/ViewModels/TimerViewModel.swift:358`
- Trigger: Change a slider and force-quit before any path calls `saveState()`.
- Workaround: Start/stop the timer or background the app after changing settings. Fix with `didSet` persistence for `goal` and `danger` or explicit save actions from `SettingsView`.

**Reminder duration options diverge between screens:**
- Symptoms: Settings offers `15` minutes but the long-press wheel offers `1` minute and omits `15`.
- Files: `Retainer Tracker/Views/SettingsView.swift:53`, `Retainer Tracker/Views/Components/TimerButtonView.swift:57`
- Trigger: Select `15 minutes` in Settings, then open the long-press reminder picker on Home.
- Workaround: Use reminder values that exist in both controls. Fix by sourcing both controls from one `AppConfig.Timer.reminderOptions` list.

**Midnight rollover can carry previous-day accumulated time into the new day:**
- Symptoms: When a running timer crosses midnight, `handleMidnightCrossing` records the pre-midnight session, then subtracts only that active-session duration from `timerEngine.accumulatedTime`. Completed sessions from the previous day can remain in the new day's accumulated total.
- Files: `Retainer Tracker/ViewModels/TimerViewModel.swift:382`, `Retainer Tracker/ViewModels/TimerViewModel.swift:391`, `Retainer Tracker/ViewModels/TimerViewModel.swift:399`, `Retainer Tracker/ViewModels/TimerViewModel.swift:401`
- Trigger: Record completed sessions before midnight, start another session before midnight, and keep it running past midnight.
- Workaround: Manually delete or reset affected sessions. Fix by splitting intervals at day boundaries and recalculating the new day from sessions starting at `today`, not by subtracting from an accumulated scalar.

**Cross-day edited sessions are assigned wholly to the start date:**
- Symptoms: Daily history and streak calculations group sessions by `session.start`, so any session that spans midnight contributes its full duration to the start day.
- Files: `Retainer Tracker/ViewModels/TimerViewModel.swift:210`, `Retainer Tracker/Views/StatsView.swift:343`, `Retainer Tracker/Models/Session.swift:28`, `Retainer Tracker/Views/StatsView.swift:380`
- Trigger: Edit a session so its start and end dates span two calendar days.
- Workaround: Split the session manually into separate day-bounded sessions. Fix by calculating per-day segments from `(start, end)` intervals before grouping.

**Live Activity state can become stale after settings/session edits:**
- Symptoms: `LiveActivityManager.update` exists but `TimerViewModel` only calls `start` and `stop`; goal/danger changes and session recalculations do not push updated content state.
- Files: `Retainer Tracker/Services/LiveActivityManager.swift:73`, `Retainer Tracker/ViewModels/TimerViewModel.swift:138`, `Retainer Tracker/ViewModels/TimerViewModel.swift:149`, `Retainer Tracker/ViewModels/TimerViewModel.swift:330`
- Trigger: Change thresholds while a Live Activity is active, or edit/delete sessions while the timer display is active.
- Workaround: Stop and restart the timer. Fix by calling `LiveActivityManager.update` from settings changes and accumulated-time recalculation, with throttling if updates are tied to timer ticks.

## Security Considerations

**Health-adjacent timer state is stored in shared UserDefaults:**
- Risk: Timer state, reminder timing, and goal thresholds are stored in an App Group container readable by the app and widget extension. The fallback to standard defaults can leave data outside the shared container after migration.
- Files: `Retainer Tracker/Services/PersistenceService.swift:64`, `Retainer Tracker/Services/PersistenceService.swift:71`, `Retainer Tracker/Services/PersistenceService.swift:74`, `Retainer Tracker/Services/PersistenceService.swift:98`
- Current mitigation: Access is limited to the app and extension with the configured App Group entitlements.
- Recommendations: Keep the stored state minimal, remove migrated standard-default values after successful migration, and use protected storage if future data becomes more sensitive than timer display state.

**Notification permission is requested on startup:**
- Risk: The app asks for notification authorization from `ContentView.task` before the user explicitly configures reminders.
- Files: `Retainer Tracker/Views/ContentView.swift:47`, `Retainer Tracker/Services/NotificationService.swift:30`
- Current mitigation: The result is ignored and reminders still guard against zero-minute scheduling.
- Recommendations: Request permission when the user enables or starts a nonzero reminder, then surface denied permission in reminder UI.

**Logging uses `print` for operational failures:**
- Risk: Console output is unstructured and cannot express privacy boundaries if error messages later include user-specific details.
- Files: `Retainer Tracker/Services/NotificationService.swift:70`
- Current mitigation: The current logged message only includes notification scheduling failure text.
- Recommendations: Replace `print` with `Logger` and mark interpolated values with appropriate privacy levels.

## Performance Bottlenecks

**Timer publishes UI updates every 100ms:**
- Problem: `TimerEngine` updates `currentProgress` ten times per second, which drives SwiftUI updates through `TimerViewModel`.
- Files: `Retainer Tracker/Utils/AppConfig.swift:27`, `Retainer Tracker/Services/TimerEngine.swift:159`, `Retainer Tracker/ViewModels/TimerViewModel.swift:313`, `Retainer Tracker/Views/HomeView.swift:34`
- Cause: The timer display mostly renders seconds, while the update cadence is configured for sub-second animation.
- Improvement path: Use a one-second cadence for state and display, or separate a lightweight animation-only progress source from persisted/published timer state.

**Session operations fetch and recompute full history:**
- Problem: `SessionManager` loads all sessions into memory, then stats and charts regroup or filter that array during view rendering.
- Files: `Retainer Tracker/Services/SessionManager.swift:113`, `Retainer Tracker/ViewModels/TimerViewModel.swift:206`, `Retainer Tracker/Views/StatsView.swift:331`
- Cause: There are no date-scoped `FetchDescriptor` calls or cached daily aggregates.
- Improvement path: Fetch only the visible date range for charts and today's sessions, and calculate streaks from daily aggregates instead of all raw sessions.

**Bulk deletion saves and reloads per row:**
- Problem: `deleteAllTodaySessions()` loops through today's sessions and calls `SessionManager.deleteSession`, which saves and reloads every time.
- Files: `Retainer Tracker/ViewModels/TimerViewModel.swift:296`, `Retainer Tracker/ViewModels/TimerViewModel.swift:300`, `Retainer Tracker/Services/SessionManager.swift:79`
- Cause: Single-row service API is reused for batch deletion.
- Improvement path: Add a batch delete method that deletes all matching sessions, saves once, reloads once, then recalculates accumulated time once.

## Fragile Areas

**Timer and reminder tasks are not isolated to a single actor:**
- Files: `Retainer Tracker/Services/TimerEngine.swift:43`, `Retainer Tracker/Services/TimerEngine.swift:161`, `Retainer Tracker/Services/ReminderManager.swift:40`, `Retainer Tracker/Services/ReminderManager.swift:109`
- Why fragile: `TimerEngine` and `ReminderManager` are `ObservableObject` classes that mutate `@Published` state from main-actor blocks while their task loops also read instance state. Strict Swift concurrency settings can expose these as data-race risks.
- Safe modification: Mark these classes `@MainActor` or isolate mutable timing state behind an actor. Keep task loops reading snapshots through actor-isolated methods.
- Test coverage: No tests cover pause/resume, cancellation, or repeated start/stop races.

**SwiftData startup has no recovery path:**
- Files: `Retainer Tracker/App/TrayOff.swift:32`, `Retainer Tracker/App/TrayOff.swift:36`, `Retainer Tracker/App/TrayOff.swift:42`, `Retainer Tracker/Models/Session.swift:16`
- Why fragile: A container creation, migration, or store-corruption failure terminates the app with `fatalError`.
- Safe modification: Add a recoverable app state that can show an error screen, offer store reset/export diagnostics, and preserve crash details through `Logger`.
- Test coverage: No migration, corrupt-store, or first-launch persistence tests are present.

**Live Activity lifecycle has silent failure and single-activity assumptions:**
- Files: `Retainer Tracker/Services/LiveActivityManager.swift:21`, `Retainer Tracker/Services/LiveActivityManager.swift:30`, `Retainer Tracker/Services/LiveActivityManager.swift:57`, `Retainer Tracker/Services/LiveActivityManager.swift:62`, `Retainer Tracker/Services/LiveActivityManager.swift:95`
- Why fragile: The manager reconnects to only the first existing activity, does not end stale extras before starting, and ignores request errors.
- Safe modification: Check `ActivityAuthorizationInfo`, end stale activities during startup, log request failures, and model active activity state explicitly.
- Test coverage: No tests or diagnostics cover disabled Live Activities, duplicate activities, or stale activity cleanup.

**Preview code force-unwraps model containers:**
- Files: `Retainer Tracker/Views/ContentView.swift:57`, `Retainer Tracker/Views/HomeView.swift:121`, `Retainer Tracker/Views/StatsView.swift:409`, `Retainer Tracker/Views/SettingsView.swift:80`, `Retainer Tracker/Views/Components/TimerButtonView.swift:186`, `Retainer Tracker/Views/Components/TimerRingView.swift:78`
- Why fragile: Xcode previews can crash instead of showing fallback content when in-memory SwiftData setup fails.
- Safe modification: Add a shared preview factory that returns a known-good container or a visible failure placeholder for preview-only use.
- Test coverage: No preview-support code is tested.

## Scaling Limits

**History model scales linearly with raw sessions:**
- Current capacity: All sessions are fetched and retained in `SessionManager.sessions`.
- Limit: Stats, streaks, chart data, and today's-session filters all become O(total sessions) as history grows.
- Scaling path: Add date-indexed fetches and daily aggregate records for long-term history.

**Widget timeline updates are coarse for a running timer:**
- Current capacity: The widget creates one entry and refreshes every 15 minutes unless the app calls `WidgetCenter.shared.reloadAllTimelines()`.
- Limit: A home-screen widget can display stale running-time/status between system timeline refreshes.
- Scaling path: Generate multiple timeline entries while running, use a shorter policy where allowed, or make widget copy explicitly state that live precision belongs to Live Activities.

## Dependencies at Risk

**iOS 26 and Xcode 26 APIs narrow the build/runtime surface:**
- Risk: The app and widget entry points are marked `@available(iOS 26.0, *)`, project targets deploy to iOS 26.0, and UI uses iOS 26 glass APIs.
- Impact: The project requires an iOS 26 SDK and cannot run on earlier iOS versions even though `Package.swift` declares iOS 14.
- Migration plan: Keep the iOS 26 target if intentional and remove conflicting package metadata, or introduce availability-gated fallbacks and lower `IPHONEOS_DEPLOYMENT_TARGET`.

**SwiftData model has no explicit migration plan:**
- Risk: `Session` is the only model and stores `id`, `start`, and `end` without versioned schema handling.
- Impact: Future model changes can trigger store migration failures that currently become an app crash.
- Migration plan: Add schema versioning before changing `Session`, and test upgrades from the existing store shape.

## Missing Critical Features

**Automated tests are absent:**
- Problem: No `*Tests.swift`, `*.test.swift`, `*.spec.swift`, or `.xctestplan` files are present; schemes rely on autogenerated test plans without test targets.
- Blocks: Safe changes to timer rollover, persistence, Live Activities, and statistics are difficult to validate.

**User-visible data recovery is absent:**
- Problem: Persistence and SwiftData failures either return empty state, silently ignore writes, or crash.
- Blocks: Users cannot recover or report actionable diagnostics when session history fails to load or save.

## Test Coverage Gaps

**Timer lifecycle and midnight rollover:**
- What's not tested: Start/stop, pause/resume, force-quit restore, background elapsed time, and midnight session splitting.
- Files: `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/ViewModels/TimerViewModel.swift`
- Risk: Timer totals and daily history can drift without detection.
- Priority: High

**Persistence and widget state compatibility:**
- What's not tested: Encoding/decoding `TimerState`, App Group fallback, migration from standard defaults, and widget decoding of app-written state.
- Files: `Retainer Tracker/Services/PersistenceService.swift`, `RetainerWidget/RetainerWidget.swift`
- Risk: Widget display and restored timer state can silently break after schema changes.
- Priority: High

**Statistics and session editing:**
- What's not tested: Streak math, last-7-days chart data, deletion, editing, and cross-day sessions.
- Files: `Retainer Tracker/ViewModels/TimerViewModel.swift`, `Retainer Tracker/Views/StatsView.swift`, `Retainer Tracker/Services/SessionManager.swift`
- Risk: User-facing stats can be incorrect after common edits.
- Priority: High

**Notification and Live Activity failure paths:**
- What's not tested: Denied notification permission, failed scheduling, disabled Live Activities, duplicate Live Activities, and stale activity cleanup.
- Files: `Retainer Tracker/Services/NotificationService.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`
- Risk: Reminder and Lock Screen behavior can fail without UI feedback.
- Priority: Medium

---

*Concerns audit: 2026-05-02*
