# TrayOff App Store Polish

## What This Is

TrayOff is an iOS app for tracking the amount of time a user has their retainer off. The core app already exists: users can start and stop a timer, record retainer-off sessions, see today's stats, adjust goals and reminders, use a widget, and see Live Activity status. This project turns that finished core into a more polished App Store app, then grows it with history, better statistics, and a more useful Live Activity.

## Core Value

TrayOff must make retainer-off time easy to track, review, and trust so users can build a healthier daily habit.

## Requirements

### Validated

- Shipped: User can start and stop a retainer-off timer.
- Shipped: User sessions are persisted with SwiftData.
- Shipped: User can view today's sessions and basic statistics.
- Shipped: User can edit, delete, undo, and bulk-delete today's sessions.
- Shipped: User can configure goal, danger, reminder, and goal-status preferences.
- Shipped: User can receive local reminder notifications.
- Shipped: User can see TrayOff state in a home-screen widget.
- Shipped: User can see active timer status through a Live Activity and Dynamic Island.
- Shipped: User sees first-launch onboarding.

### Active

- [ ] Tighten the UI so TrayOff feels more intentional and less "AI-ish" while preserving the existing product shape.
- [ ] Make historical session logs visible beyond the current day.
- [ ] Build richer statistics from multi-day session history.
- [ ] Improve Live Activity reliability, usefulness, and visual polish.
- [ ] Harden timer/session persistence, settings persistence, midnight rollover, and cross-day session behavior.
- [ ] Prepare the app for App Store-quality release confidence through QA, targeted tests, and release-readiness checks.

### Out of Scope

- Apple Watch app - desirable stretch goal, but last attempt was difficult and it should not block the App Store polish milestone.
- Full visual redesign - the goal is tightening the finished app, not replacing its identity or interaction model.
- Cloud sync, accounts, social features, or clinician workflows - not needed for the current solo habit-tracking value.
- Monetization or subscriptions - not part of the current product polish and feature-growth milestone.

## Context

TrayOff is a SwiftUI iOS application with a WidgetKit extension. The app uses SwiftData for `Session` history, ActivityKit for Live Activities, local notifications for reminders, and App Group `UserDefaults` to share timer state with widgets.

The codebase map identifies the current architecture as SwiftUI MVVM with `TimerViewModel` coordinating timer state, sessions, persistence, reminders, widgets, and Live Activities. Existing sessions are already stored beyond a day at the database level; the visible product work is to expose longer-term history, group it well, and make the statistics trustworthy as history grows.

The user considers the current app largely finished. This project should focus on product polish and forward feature growth rather than rebuilding the foundation from scratch.

Known issues and risks from the codebase map should directly shape planning:

- Goal and danger settings are saved in `TimerState` but not restored on launch.
- Goal and danger slider changes are not saved immediately.
- Reminder duration options differ between Settings and the Home long-press picker.
- Midnight rollover can carry prior-day accumulated time into the new day.
- Cross-day sessions are grouped wholly by their start date.
- Live Activity state can become stale after settings or session edits.
- Session queries and stats currently scale linearly over all raw sessions.
- Automated tests are absent, so timer, stats, persistence, and Live Activity work need focused coverage or manual QA notes.

## Constraints

- **Platform**: iOS app plus WidgetKit extension - changes must respect app and extension target boundaries.
- **Tech stack**: SwiftUI, SwiftData, WidgetKit, ActivityKit, Combine, UserNotifications - prefer existing Apple framework patterns already in the codebase.
- **Build surface**: Use `TrayOff.xcodeproj` as the source of truth for app/widget work; `Package.swift` is stale for full app builds.
- **Design scope**: Tighten the current UI rather than creating a new marketing-style redesign.
- **Data integrity**: History and stats must treat cross-day sessions and midnight rollover carefully before presenting broader historical insights.
- **Verification**: A full Xcode installation is required for `xcodebuild`; this shell currently has Command Line Tools only.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Treat this as an existing-product polish milestone | The core timer app already exists and the user wants App Store polish plus incremental features. | - Pending |
| Prioritize history, stats, Live Activity, and hardening before Apple Watch | These are closer to current user value and lower risk than a watchOS target. | - Pending |
| Keep Apple Watch as stretch scope | The user is interested but noted prior difficulty; it should not block the main milestone. | - Pending |
| Make UI tightening a product pass, not a full redesign | The user wants the app to look less AI-ish, but mainly sees it as finished. | - Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check - still the right priority?
3. Audit Out of Scope - reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-02 after initialization*
