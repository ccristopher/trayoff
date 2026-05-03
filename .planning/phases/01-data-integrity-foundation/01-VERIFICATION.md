# Phase 1: Data Integrity Foundation - Verification

## Phase 1 Verification Matrix

| Requirement | Decision IDs | Static Check | Runtime or Manual Check | Status |
|-------------|--------------|--------------|--------------------------|--------|
| REL-01 | D-11, D-12, D-13 | Confirm `TimerViewModel` restores `state.goal`, restores `state.danger`, saves threshold changes, and clamps `danger < goal`. | Settings persistence manual QA. | Static passed; manual pending |
| REL-02 | D-01, D-02, D-03, D-04, D-05 | Confirm Settings and Home long-press picker both use `AppConfig.Timer.reminderOptions`. | Reminder option parity manual QA. | Static passed; manual pending |
| REL-03 | D-06, D-08 | Confirm midnight rollover no longer inserts a split session or moves `currentSessionStart`; confirm `elapsedToday` resets visible progress. | Active timer across midnight manual QA. | Static passed; manual pending |
| REL-04 | D-07, D-09, D-10 | Confirm `SessionDayAllocator` is used for daily totals, streaks, and chart data. | Manual cross-midnight session edit QA. | Static passed; manual pending |
| QA-01 | D-14, D-15, D-16 | Confirm this artifact records static checks, build/test outcome, and manual QA scenarios. | Complete the verification checklist before Phase 1 close. | In progress |

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
