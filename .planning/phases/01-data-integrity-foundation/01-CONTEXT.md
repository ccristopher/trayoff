# Phase 1: Data Integrity Foundation - Context

**Gathered:** 2026-05-02
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase makes TrayOff's stored timer, settings, reminder configuration, and day-by-day session math trustworthy before history, stats, UI polish, and Live Activity upgrades build on top of them. It covers settings persistence, shared reminder options, midnight rollover behavior, cross-day session allocation, and a focused verification path. It does not add historical browsing UI, richer chart UI, Live Activity redesign, or Apple Watch support.

</domain>

<decisions>
## Implementation Decisions

### Reminder Options
- **D-01:** The canonical reminder duration list is `0, 15, 20, 30, 60` minutes.
- **D-02:** New installs default to `0 minutes`; reminders are opt-in and should not schedule notifications until the user chooses a nonzero duration.
- **D-03:** Users can change reminder duration in both Settings and the Home long-press picker.
- **D-04:** Settings and Home long-press MUST read from the same shared reminder options source, preferably under `AppConfig`, so they cannot drift again.
- **D-05:** If the timer is already running and the user changes the default reminder in Settings, the active countdown keeps running. The new value applies to the next session only.

### Midnight Sessions
- **D-06:** Cross-midnight sessions should remain one continuous session in the user's log.
- **D-07:** Stats and daily totals must split cross-midnight duration behind the scenes by actual minutes per calendar day.
- **D-08:** If an active timer crosses midnight, Home should show the new day's daily total only. The active session continues for logging, but daily goal/danger progress resets at midnight.
- **D-09:** Manual session edits may cross midnight. The date+time editor can continue allowing cross-day ranges; validation should focus on `end >= start`.
- **D-10:** The existing "count wholly on start day" behavior is explicitly rejected for daily totals, streaks, and future history/stat views.

### Settings Behavior
- **D-11:** The agent may choose the exact persistence mechanism, but goal and danger threshold changes must persist immediately and restore after relaunch.
- **D-12:** Goal/danger changes should apply immediately to the app's current display state. If the timer is running, update the active daily status without stopping or restarting the timer.
- **D-13:** Danger must remain greater than or equal to goal. If changing goal would make danger invalid, clamp or adjust safely rather than allowing inconsistent thresholds.

### Verification Confidence
- **D-14:** Prefer focused automated tests for pure/session math and persistence behavior if a test target can be added cleanly.
- **D-15:** If local `xcodebuild` is blocked by missing full Xcode in this environment, document manual QA steps for the same behaviors instead of pretending verification happened.
- **D-16:** Phase 1 is not done until settings persistence, shared reminders, midnight rollover, cross-day allocation, and the chosen verification path are all covered.

### the agent's Discretion
- The agent may decide the internal shape of any daily allocation helper, as long as user-visible logs stay continuous and stats split by actual per-day minutes.
- The agent may decide whether verification starts as XCTest, Swift Testing, or documented manual QA, but should prefer the smallest credible path that works with the Xcode project.
- The agent may decide the exact UI feedback for Settings persistence; no new confirmation flow is required in Phase 1.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Planning Scope
- `.planning/PROJECT.md` - Project goals, constraints, and known issue context for the App Store polish milestone.
- `.planning/REQUIREMENTS.md` - Phase 1 requirements `REL-01`, `REL-02`, `REL-03`, `REL-04`, and `QA-01`.
- `.planning/ROADMAP.md` - Phase 1 goal, success criteria, and planned plan split.
- `.planning/STATE.md` - Current project position and known environment constraints.

### Codebase Maps
- `.planning/codebase/CONCERNS.md` - Known bugs and fragile areas for settings persistence, midnight rollover, cross-day sessions, reminders, and testing gaps.
- `.planning/codebase/TESTING.md` - Existing testing state and recommended test target patterns.

### Settings and Reminders
- `Retainer Tracker/Utils/AppConfig.swift` - Existing central config namespace; should own shared reminder options and relevant persistence constants.
- `Retainer Tracker/Services/ReminderManager.swift` - Current reminder default persistence and countdown behavior.
- `Retainer Tracker/Views/SettingsView.swift` - Current Settings picker uses `0, 15, 20, 30, 60`.
- `Retainer Tracker/Views/Components/TimerButtonView.swift` - Current Home long-press picker uses `0, 1, 20, 30, 60`.

### Timer and Sessions
- `Retainer Tracker/ViewModels/TimerViewModel.swift` - Current settings load/save, midnight rollover, accumulated-time recalculation, and session orchestration.
- `Retainer Tracker/Services/TimerEngine.swift` - Current daily accumulated time and running timer behavior.
- `Retainer Tracker/Models/Session.swift` - Existing continuous session model with `start`, `end`, and computed `duration`.
- `Retainer Tracker/Services/SessionManager.swift` - Current SwiftData session CRUD and all-session fetch behavior.
- `Retainer Tracker/Views/StatsView.swift` - Current chart grouping by `session.start`, edit sheet, and daily history display logic.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppConfig`: Existing nested namespace for timer, persistence, UI, and animation constants. Add shared reminder options here to prevent Settings/Home drift.
- `TimerState`: Already contains optional `goal` and `danger`; Phase 1 should load/apply these values and persist changes promptly.
- `Session`: Already supports continuous cross-day sessions because it stores start and end dates. No new split-session model is required for Phase 1.
- `EditSessionView`: Already allows date+time edits, so cross-midnight manual edits can remain supported.

### Established Patterns
- `TimerViewModel` is the screen-facing coordinator. Settings persistence, midnight rollover, and recalculated daily totals should route through it or focused collaborators it owns.
- Services are protocol-backed where useful. Verification can use existing injection seams around `TimerPersistenceServiceProtocol` and in-memory SwiftData containers.
- User-facing views call view-model methods and render published state; avoid pushing timer/session math directly into SwiftUI views.

### Integration Points
- Reminder options connect `AppConfig`, `ReminderManager.selectedReminder`, `SettingsView`, and `TimerButtonView`.
- Goal/danger persistence connects `SettingsView`, `TimerViewModel.goal`, `TimerViewModel.danger`, `TimerState`, and widget/Live Activity state later.
- Cross-day allocation connects `Session` intervals, `TimerViewModel.getStreakStats()`, `TimerViewModel.recalculateAccumulatedTime()`, and `StatsView` history data helpers.
- Midnight rollover connects `TimerViewModel.checkForMidnightReset()`, `handleMidnightCrossing(today:)`, `TimerEngine`, and `SessionManager`.

</code_context>

<specifics>
## Specific Ideas

- Reminder behavior should feel quiet and App Store-polished: reminders are off by default and no extra confirmation UI is needed.
- Session history should stay human-readable as continuous sessions even when stats split duration internally.
- The daily goal/danger concept is a day boundary, so Home progress should reset at midnight even if the active session continues.

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within phase scope.

</deferred>

---

*Phase: 1-Data Integrity Foundation*
*Context gathered: 2026-05-02*
