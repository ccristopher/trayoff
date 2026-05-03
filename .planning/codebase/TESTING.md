---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: quality
---
# Testing Patterns

**Analysis Date:** 2026-05-02

## Test Framework

**Runner:**
- XCTest is the natural runner for this Xcode/iOS project, but no executable test target is configured in the repository.
- `TrayOff.xcodeproj/xcshareddata/xcschemes/Retainer Tracker.xcscheme` and `TrayOff.xcodeproj/xcshareddata/xcschemes/RetainerWidgetExtension.xcscheme` contain empty `TestAction` sections with `shouldAutocreateTestPlan = "YES"`.
- `TrayOff.xcodeproj/project.pbxproj` defines app and widget targets only: `TrayOff` and `RetainerWidgetExtension`.
- `Package.swift` defines a single library target named `TrayOff` and no `.testTarget`.
- No `*Tests.swift`, `*UITests.swift`, `*.xctestplan`, `*.test.*`, or `*.spec.*` files are present.

**Assertion Library:**
- XCTest assertions should be used when a test target is added: `XCTAssertEqual`, `XCTAssertTrue`, `XCTAssertFalse`, `XCTAssertNil`, `XCTAssertNotNil`.
- Snapshot or view-inspection assertion libraries are not configured.

**Run Commands:**
```bash
xcodebuild test -project TrayOff.xcodeproj -scheme "Retainer Tracker" -destination 'platform=iOS Simulator,name=iPhone 16'              # Run app tests after adding an XCTest target
xcodebuild test -project TrayOff.xcodeproj -scheme "Retainer Tracker" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:TrayOffTests/TimerViewModelTests  # Run one suite
xcodebuild test -project TrayOff.xcodeproj -scheme "Retainer Tracker" -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES                         # Run with coverage
```

`xcodebuild` requires a full Xcode developer directory. A Command Line Tools-only developer directory is not enough for the project.

Do not rely on `swift test` until `Package.swift` includes a `.testTarget`. `swift package describe --type text` reports only the `TrayOff` library target at `Retainer Tracker/`.

## Test File Organization

**Location:**
- Add app unit tests in a sibling Xcode test target directory named `Retainer TrackerTests/` or `TrayOffTests/`.
- Add widget-specific tests in `RetainerWidgetTests/` only when testing widget timeline/provider logic separately from the app.
- If SwiftPM test support is added, place tests under `Tests/TrayOffTests/` and update `Package.swift` with `.testTarget(name: "TrayOffTests", dependencies: ["TrayOff"])`.

**Naming:**
- Name files after the type or workflow under test: `TimerViewModelTests.swift`, `TimeFormatterTests.swift`, `SessionManagerTests.swift`, `PersistenceServiceTests.swift`.
- Name test classes with the same suffix: `final class TimerViewModelTests: XCTestCase`.
- Name test methods as `test_condition_expectedOutcome()`, for example `testFormatWithHours_returnsHourMinuteSecondString()`.

**Structure:**
```text
TrayOffTests/
├── ViewModels/
│   └── TimerViewModelTests.swift
├── Services/
│   ├── SessionManagerTests.swift
│   ├── TimerEngineTests.swift
│   └── PersistenceServiceTests.swift
└── Utils/
    └── TimeFormatterTests.swift
```

## Test Structure

**Suite Organization:**
```swift
import XCTest
import SwiftData
@testable import TrayOff

@MainActor
final class SessionManagerTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Session.self, configurations: config)
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
    }

    func testAddSession_persistsSessionAndReloadsList() throws {
        let manager = SessionManager(modelContext: context)
        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        let end = start.addingTimeInterval(600)

        manager.addSession(start: start, end: end)

        XCTAssertEqual(manager.sessions.count, 1)
        XCTAssertEqual(manager.sessions.first?.duration, 600)
    }
}
```

**Patterns:**
- Use `@MainActor` on XCTest classes that instantiate `TimerViewModel`, `SessionManager`, SwiftData `ModelContext`, or ActivityKit-facing code because the app marks these coordinators as main-actor types.
- Use an in-memory `ModelContainer` for tests that touch `Session`. This mirrors the `#Preview` setup in `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, and `Retainer Tracker/Views/SettingsView.swift`.
- Keep fixed `Date` values in tests. Avoid assertions that depend on wall-clock `Date()` unless testing rollover behavior explicitly.
- Test pure utility code without SwiftUI or SwiftData setup. `Retainer Tracker/Utils/TimeFormatter.swift` can be tested with direct static function calls.
- Keep async timer tests short and deterministic. Prefer dependency seams for clocks or persisted state over waiting for real elapsed time.

## Mocking

**Framework:** XCTest hand-written test doubles

**Patterns:**
```swift
final class FakeTimerPersistenceService: TimerPersistenceServiceProtocol {
    private(set) var savedState: TimerState?
    var stateToLoad: TimerState?

    func saveTimerState(_ state: TimerState) {
        savedState = state
    }

    func loadTimerState() -> TimerState? {
        stateToLoad
    }
}
```

**What to Mock:**
- Mock `TimerPersistenceServiceProtocol` for `TimerViewModel` persistence behavior. The initializer already accepts `persistenceService: TimerPersistenceServiceProtocol` in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Use protocol-backed test doubles for services that already define protocols: `TimerEngineProtocol`, `ReminderManagerProtocol`, `SessionManagerProtocol`, and `TimerPersistenceServiceProtocol` under `Retainer Tracker/Services/`.
- Wrap platform APIs before testing side effects from `NotificationService.shared` or `LiveActivityManager.shared`; direct calls reach `UNUserNotificationCenter` and ActivityKit in `Retainer Tracker/Services/NotificationService.swift` and `Retainer Tracker/Services/LiveActivityManager.swift`.

**What NOT to Mock:**
- Do not mock `TimeFormatter` or `AppConfig`; test their real static values and pure formatting behavior directly.
- Do not mock SwiftData `ModelContext` for CRUD tests. Use an in-memory `ModelContainer` so `SessionManager` exercises actual SwiftData behavior.
- Do not mock SwiftUI views for business logic. Move logic into `TimerViewModel`, services, or utility types and test those directly.

## Fixtures and Factories

**Test Data:**
```swift
enum TestSessions {
    static let morningStart = Date(timeIntervalSinceReferenceDate: 10_000)

    static func session(duration: TimeInterval = 600) -> Session {
        Session(start: morningStart, end: morningStart.addingTimeInterval(duration))
    }

    static func timerState(isRunning: Bool = false) -> TimerState {
        TimerState(
            startTime: morningStart.timeIntervalSinceReferenceDate,
            isRunning: isRunning,
            accumulatedTime: 600,
            lastResetDate: Calendar.current.startOfDay(for: morningStart),
            reminderStartTime: nil,
            currentSessionStart: nil,
            goal: AppConfig.Timer.defaultGoal,
            danger: AppConfig.Timer.defaultDanger
        )
    }
}
```

**Location:**
- Put reusable factories under `TrayOffTests/Fixtures/` or `Retainer TrackerTests/Fixtures/`.
- Keep fixtures test-only. Do not add fixture helpers to `Retainer Tracker/` production source.
- Keep date fixtures fixed and named around the behavior they support, such as `yesterdaySession`, `todaySession`, or `overGoalSession`.

## Coverage

**Requirements:** None enforced. No coverage threshold or CI coverage gate is configured.

**View Coverage:**
```bash
xcodebuild test -project TrayOff.xcodeproj -scheme "Retainer Tracker" -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES
```

High-value coverage targets:
- `Retainer Tracker/Utils/TimeFormatter.swift`: formatting boundaries for seconds, minutes, hours, and pluralized descriptions.
- `Retainer Tracker/Services/SessionManager.swift`: add, update, delete, undo, stats, and fetch ordering with an in-memory `ModelContainer`.
- `Retainer Tracker/Services/PersistenceService.swift`: encode/decode behavior through `TimerState`, ideally after adding injectable `UserDefaults` storage.
- `Retainer Tracker/Services/TimerEngine.swift`: start, stop, reset, pause, resume, and accumulated time calculations.
- `Retainer Tracker/ViewModels/TimerViewModel.swift`: toggle flow, midnight reset, stats/streak calculations, session deletion, and save/load behavior.

## Test Types

**Unit Tests:**
- Use for pure functions and service logic: `TimeFormatter`, `AppConfig`, `TimerEngine`, `ReminderManager`, and `TimerViewModel` calculations.
- Prefer deterministic inputs over real time. For new logic that depends on `Date()` or `ProcessInfo.processInfo.systemUptime`, add injectable clock seams before broadening test coverage.

**Integration Tests:**
- Use for SwiftData-backed behavior in `SessionManager` with in-memory `ModelContainer`.
- Use for persisted timer state only after `TimerPersistenceService` accepts an injectable `UserDefaults` or storage abstraction. The production implementation uses an App Group suite in `Retainer Tracker/Services/PersistenceService.swift`.
- Use for widget timeline entry derivation in `RetainerWidget/RetainerWidget.swift` with controlled encoded `TimerState` data.

**E2E Tests:**
- Not used. No UI test target, no `*UITests.swift` files, and no automated simulator workflow are present.
- If UI tests are added, focus on first-launch onboarding, starting/stopping the timer, editing a session, settings changes, and notification permission handling.

## Common Patterns

**Async Testing:**
```swift
@MainActor
func testRequestPermissions_whenServiceFails_returnsFalse() async {
    // Add an injectable notification center wrapper before testing this path.
    // Direct NotificationService.shared calls use UNUserNotificationCenter.current().
}
```

For existing async loops in `Retainer Tracker/Services/TimerEngine.swift` and `Retainer Tracker/Services/ReminderManager.swift`, avoid long sleeps in tests. Add clock or scheduler injection before asserting fine-grained countdown behavior.

**Error Testing:**
```swift
func testLoadTimerState_whenNoData_returnsNil() {
    let persistence = FakeTimerPersistenceService()

    XCTAssertNil(persistence.loadTimerState())
}
```

For SwiftData failures, assert observable fallback state at the service boundary. `SessionManager.loadSessions()` converts fetch errors into `sessions = []`, so tests should assert the published state rather than thrown errors.

**Preview Smoke Coverage:**
- Existing `#Preview` blocks are visual smoke scaffolds, not tests. They appear in `Retainer Tracker/Views/ContentView.swift`, `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/SettingsView.swift`, `Retainer Tracker/Views/StatsView.swift`, and component files under `Retainer Tracker/Views/Components/`.
- Keep previews compiling when changing view initializers because they are the only repo-local executable examples of view construction.

---

*Testing analysis: 2026-05-02*
