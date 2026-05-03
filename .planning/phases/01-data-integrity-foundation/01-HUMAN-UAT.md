---
status: partial
phase: 01-data-integrity-foundation
source: [01-VERIFICATION.md]
started: 2026-05-03T04:32:27Z
updated: 2026-05-03T04:32:27Z
---

# Phase 1 Human UAT

## Current Test

Awaiting manual testing in a full Xcode simulator or device environment.

## Tests

### 1. Settings persistence

expected: Change goal and danger, force quit, relaunch, and confirm restored values. If goal is raised above danger, danger is clamped to goal.
result: pending

### 2. Reminder option parity

expected: Settings and Home long-press both show `0, 15, 20, 30, 60`, and selection stores the same reminder.
result: pending

### 3. Active timer across midnight

expected: Home progress resets to the new day's elapsed total while the eventual log remains one continuous session spanning midnight.
result: pending

### 4. Manual cross-midnight session edit

expected: A session edited to `11:50 PM -> 12:10 AM` remains one log entry and allocates `10 minutes on each day`.
result: pending
