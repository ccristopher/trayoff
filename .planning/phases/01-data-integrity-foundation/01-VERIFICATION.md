---
status: human_needed
phase: 01-data-integrity-foundation
updated: 2026-05-03
human_verification:
  - Active timer across midnight
completed_human_verification:
  - Settings persistence
  - Reminder option parity
  - Manual cross-midnight session edit
---

# Phase 1: Data Integrity Foundation - Verification

## Phase 1 Verification Matrix

| Requirement | Decision IDs | Static Check | Runtime or Manual Check | Status |
|-------------|--------------|--------------|--------------------------|--------|
| REL-01 | D-11, D-12, D-13 | Confirm `TimerViewModel` restores `state.goal`, restores `state.danger`, saves threshold changes, and clamps `danger < goal`. | Settings persistence manual QA. | Passed |
| REL-02 | D-01, D-02, D-03, D-04, D-05 | Confirm Settings and Home long-press picker both use `AppConfig.Timer.reminderOptions`. | Reminder option parity manual QA. | Passed |
| REL-03 | D-06, D-08 | Confirm midnight rollover no longer inserts a split session or moves `currentSessionStart`; confirm `elapsedToday` resets visible progress. | Active timer across midnight manual QA. | Static passed; manual pending |
| REL-04 | D-07, D-09, D-10 | Confirm `SessionDayAllocator` is used for daily totals, streaks, and chart data. | Manual cross-midnight session edit QA. | Passed |
| QA-01 | D-14, D-15, D-16 | Confirm this artifact records static checks, build/test outcome, and manual QA scenarios. | Complete the verification checklist before Phase 1 close. | Partial: 3 of 4 human checks passed |

## Static Checks

Do not edit TrayOff.xcodeproj/project.pbxproj during Phase 1 verification; it has an existing user modification outside this phase's planning docs.

| Check | Command | Result | Notes |
|-------|---------|--------|-------|
| Shared reminder picker source | `rg "AppConfig\\.Timer\\.reminderOptions" "Retainer Tracker/Views/SettingsView.swift" "Retainer Tracker/Views/Components/TimerButtonView.swift"` | Passed | Both Settings and Home long-press picker use the shared list. |
| Goal and danger persistence/clamping | `rg "if let savedGoal = state.goal|if let savedDanger = state.danger|danger < goal" "Retainer Tracker/ViewModels/TimerViewModel.swift"` | Passed | Saved thresholds restore and `danger < goal` clamp paths are present. |
| Per-day allocation usage | `rg "SessionDayAllocator" "Retainer Tracker/ViewModels/TimerViewModel.swift" "Retainer Tracker/Views/StatsView.swift"` | Passed | Timer totals, streaks, and chart data call the allocator. |
| Removed midnight split behavior | `rg "sessionManager.addSession\\(start: start, end: midnight\\)|currentSessionStart = midnight" "Retainer Tracker/ViewModels/TimerViewModel.swift"` | Passed | No matches found. |

## Build/Test Command

Command:

```bash
xcodebuild -project TrayOff.xcodeproj -scheme "Retainer Tracker" -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Result: Blocked - full Xcode required

Observed error:

```text
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
```

## Manual QA Scenarios

### Settings persistence

Status: Passed

Steps:
1. Open Settings.
2. Change Goal to a non-default value.
3. Change Danger to a value greater than or equal to Goal.
4. Force quit TrayOff.
5. Relaunch TrayOff.
6. Reopen Settings and confirm the Goal and Danger values are restored.

Expected:
- Goal and Danger match the values set before force quit.
- If Goal was raised above Danger, Danger is clamped to the Goal value instead of staying invalid.

### Reminder option parity

Status: Passed

Steps:
1. Open Settings and inspect Default Reminder options.
2. Return Home.
3. Long-press the timer button while the timer is stopped.
4. Compare the Home picker options to Settings.

Expected:
- Both controls show `0, 15, 20, 30, 60`.
- Choosing a value in either control stores the same selected reminder.

### Active timer across midnight

Status: Pending

Testing note:
- Safest path: run TrayOff on a device or simulator close to midnight, start a timer before midnight, keep the app installed and let the clock naturally cross midnight, then stop the timer after midnight.
- Confirm Home shows only the new day's elapsed amount after midnight.
- Confirm Stats shows the eventual session as one continuous log entry.
- Avoid changing the device clock while the timer is running unless intentionally testing system-clock edge cases, because the timer engine uses uptime for elapsed progress.

Steps:
1. Start the timer before midnight, or set the simulator/device clock near midnight and start a session.
2. Let the app cross midnight while the timer remains active.
3. Confirm Home progress resets to the new day's elapsed total.
4. Stop the timer after midnight.
5. Open Stats and inspect today's session row.

Expected:
- Home progress shows the new day total while the active timer continues.
- The eventual log remains one continuous session spanning midnight.
- Daily totals use only the portion that overlaps each calendar day.

### Manual cross-midnight session edit

Status: Passed

Steps:
1. Create or edit a session.
2. Set the session range to `11:50 PM -> 12:10 AM`.
3. Save the session.
4. Inspect the affected daily totals in Stats/history.

Expected:
- The session is allowed because `end >= start`.
- Allocation is `10 minutes on each day`.
- The displayed session remains a single edited log entry.
