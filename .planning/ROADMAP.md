# Roadmap: TrayOff App Store Polish

## Overview

This milestone starts by making the existing timer and session data trustworthy, then improves the visible product experience around that foundation. Once the app handles settings, midnight rollover, and cross-day sessions correctly, the roadmap tightens the UI, exposes historical logs, builds richer stats from that history, and finishes with Live Activity reliability plus App Store release readiness.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Data Integrity Foundation** - Fix persistence, rollover, cross-day allocation, and establish a verification path.
- [ ] **Phase 2: Product Polish Pass** - Tighten Home, Stats, Settings, onboarding, and app copy without redesigning TrayOff.
- [ ] **Phase 3: Historical Session Log** - Make previous-day sessions browsable, editable, and understandable.
- [ ] **Phase 4: Richer Statistics** - Build multi-day stats, trends, streaks, and low-data states on top of history.
- [ ] **Phase 5: Live Activity and Release Readiness** - Improve ActivityKit surfaces and complete App Store-quality checks.

## Phase Details

### Phase 1: Data Integrity Foundation
**Goal**: Make TrayOff's stored timer, settings, and daily session math trustworthy before expanding history and stats.
**Depends on**: Nothing (first phase)
**Requirements**: [REL-01, REL-02, REL-03, REL-04, QA-01]
**UI hint**: no
**Success Criteria** (what must be TRUE):
  1. User's custom goal and danger values survive force quit and relaunch.
  2. User sees one consistent reminder duration list across Settings and Home.
  3. User can cross midnight with an active timer and see correct daily totals.
  4. Cross-day sessions are allocated accurately instead of counted wholly on their start date.
  5. Project has a focused test target or equivalent verification path for timer and session math.
**Plans**: 3 plans

Plans:
- [ ] 01-01: Persist settings and unify reminder configuration
- [ ] 01-02: Correct midnight rollover and cross-day session allocation
- [ ] 01-03: Add focused verification for persistence and timer/session math

### Phase 2: Product Polish Pass
**Goal**: Make the existing app feel more intentional and less generated while preserving the finished core experience.
**Depends on**: Phase 1
**Requirements**: [POL-01, POL-02, POL-03, POL-04, POL-05]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Home screen hierarchy, spacing, controls, and status copy feel deliberate.
  2. Stats screen sections, empty states, edit states, and rows scan cleanly.
  3. Settings controls and labels feel consistent and explain user preferences clearly.
  4. Onboarding and app-wide copy sound concise and human.
  5. The UI still feels like TrayOff, not a full redesign.
**Plans**: 3 plans

Plans:
- [ ] 02-01: Tighten Home screen and timer controls
- [ ] 02-02: Tighten Stats, session rows, and edit/empty states
- [ ] 02-03: Tighten Settings, onboarding, and product copy

### Phase 3: Historical Session Log
**Goal**: Let users review, understand, edit, and delete sessions from previous days.
**Depends on**: Phase 1, Phase 2
**Requirements**: [REL-05, HIST-01, HIST-02, HIST-03, HIST-04]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. User can view session logs from previous days.
  2. User can browse history grouped by date.
  3. User can edit or delete historical sessions without losing today's workflow.
  4. User can see each day's total retainer-off time at a glance.
  5. History stays responsive as more sessions accumulate.
**Plans**: 3 plans

Plans:
- [ ] 03-01: Add date-scoped session queries and history data helpers
- [ ] 03-02: Build grouped history browsing UI
- [ ] 03-03: Extend edit/delete flows and daily totals to historical sessions

### Phase 4: Richer Statistics
**Goal**: Turn multi-day history into useful trend, streak, and goal-compliance insight.
**Depends on**: Phase 3
**Requirements**: [STAT-01, STAT-02, STAT-03, STAT-04, QA-02]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. User can see daily totals and session counts from stored history.
  2. User can inspect trends across the last 7 days and at least one longer range.
  3. Streak and goal-compliance stats match historical session data.
  4. Empty and low-data states help the Stats screen feel finished before charts are meaningful.
  5. Timer lifecycle, cross-day history, settings persistence, and streak math are verified by tests or manual QA.
**Plans**: 3 plans

Plans:
- [ ] 04-01: Add stats aggregation and range helpers
- [ ] 04-02: Build trend, streak, and goal-compliance UI
- [ ] 04-03: Verify stats edge cases and low-data states

### Phase 5: Live Activity and Release Readiness
**Goal**: Improve Lock Screen and Dynamic Island usefulness, then capture the checks needed for App Store confidence.
**Depends on**: Phase 4
**Requirements**: [LIVE-01, LIVE-02, LIVE-03, LIVE-04, QA-03]
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. User sees clearer elapsed time, status, and threshold progress on the Lock Screen.
  2. User sees polished Dynamic Island expanded, compact, and minimal states.
  3. Active Live Activity state updates when thresholds or accumulated time change.
  4. Duplicate, stale, disabled, or failed Live Activity states are handled visibly or logged.
  5. Release notes cover privacy/data use, notifications, Live Activities, and App Store readiness checks.
**Plans**: 3 plans

Plans:
- [ ] 05-01: Improve Live Activity state management and update paths
- [ ] 05-02: Polish Lock Screen and Dynamic Island UI
- [ ] 05-03: Complete release readiness and QA notes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Data Integrity Foundation | 0/3 | Not started | - |
| 2. Product Polish Pass | 0/3 | Not started | - |
| 3. Historical Session Log | 0/3 | Not started | - |
| 4. Richer Statistics | 0/3 | Not started | - |
| 5. Live Activity and Release Readiness | 0/3 | Not started | - |
