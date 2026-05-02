# Requirements: TrayOff App Store Polish

**Defined:** 2026-05-02
**Core Value:** TrayOff must make retainer-off time easy to track, review, and trust so users can build a healthier daily habit.

## v1 Requirements

Requirements for the App Store polish milestone. Each maps to roadmap phases.

### Reliability

- [ ] **REL-01**: User's custom goal and danger thresholds persist immediately and restore correctly after relaunch.
- [ ] **REL-02**: User sees the same reminder duration options in Settings and the Home reminder picker.
- [ ] **REL-03**: User's timer total resets cleanly at midnight without carrying previous-day accumulated time into the new day.
- [ ] **REL-04**: User sessions that cross midnight are represented accurately in daily history and statistics.
- [ ] **REL-05**: User history and stats remain responsive as stored sessions grow beyond a few days.

### Product Polish

- [ ] **POL-01**: User sees a tightened Home screen with intentional spacing, hierarchy, copy, and controls.
- [ ] **POL-02**: User sees a tightened Stats screen with clearer sections, empty states, edit states, and session rows.
- [ ] **POL-03**: User sees a tightened Settings experience with consistent controls, labels, and preference feedback.
- [ ] **POL-04**: User sees onboarding and app-wide copy that feels concise, human, and product-ready.
- [ ] **POL-05**: User-facing visual choices avoid generic generated-app patterns while preserving TrayOff's existing identity.

### History

- [ ] **HIST-01**: User can view session logs from previous days, not only today's sessions.
- [ ] **HIST-02**: User can browse session history grouped by date.
- [ ] **HIST-03**: User can edit and delete historical sessions from the history interface.
- [ ] **HIST-04**: User can understand each historical day's total retainer-off time at a glance.

### Statistics

- [ ] **STAT-01**: User can see stats calculated from multi-day history, including daily totals and session counts.
- [ ] **STAT-02**: User can inspect trend views across useful ranges such as last 7 days and longer history.
- [ ] **STAT-03**: User streak and goal-compliance stats are accurate across stored history.
- [ ] **STAT-04**: User sees useful empty and low-data states before enough history exists for charts.

### Live Activity

- [ ] **LIVE-01**: User sees a clearer Lock Screen Live Activity showing elapsed time, status, and threshold progress.
- [ ] **LIVE-02**: User sees a clearer Dynamic Island experience in expanded, compact, and minimal states.
- [ ] **LIVE-03**: User's Live Activity updates when goal, danger, or accumulated session state changes while active.
- [ ] **LIVE-04**: User does not get duplicate, stale, or silently broken Live Activities after app relaunch or ActivityKit failures.

### Release Readiness

- [ ] **QA-01**: The project has a test target or equivalent focused verification path for timer, persistence, and stats logic.
- [ ] **QA-02**: Timer lifecycle, midnight rollover, cross-day session allocation, settings persistence, and streak math are covered by tests or documented manual QA.
- [ ] **QA-03**: App Store readiness notes cover privacy/data use, notification permission behavior, Live Activity behavior, and known release checks.

## v2 Requirements

Deferred to future releases. Tracked but not in the current roadmap.

### Apple Watch

- **WATCH-01**: User can start and stop retainer-off tracking from Apple Watch.
- **WATCH-02**: User can view current timer status and reminder state from Apple Watch.
- **WATCH-03**: Watch app stays synchronized with the iPhone app's active timer and session history.

### Advanced Product Growth

- **SYNC-01**: User can sync history across devices.
- **EXPORT-01**: User can export session history for personal review or clinical conversation.
- **WIDGET-01**: User can choose from multiple widget styles or sizes beyond the current widget.

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Apple Watch app in v1 | Stretch goal with known complexity; should not block polish, history, stats, and Live Activity improvements. |
| Full redesign | User wants the app tightened, not rebuilt around a new identity. |
| Accounts or cloud sync | Not needed for the current local habit-tracking milestone. |
| Monetization | Does not help the immediate App Store polish and feature-growth goal. |
| Clinician or social workflows | Current product is a personal tracker, not a care-team platform. |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| REL-01 | Phase 1 | Pending |
| REL-02 | Phase 1 | Pending |
| REL-03 | Phase 1 | Pending |
| REL-04 | Phase 1 | Pending |
| REL-05 | Phase 3 | Pending |
| POL-01 | Phase 2 | Pending |
| POL-02 | Phase 2 | Pending |
| POL-03 | Phase 2 | Pending |
| POL-04 | Phase 2 | Pending |
| POL-05 | Phase 2 | Pending |
| HIST-01 | Phase 3 | Pending |
| HIST-02 | Phase 3 | Pending |
| HIST-03 | Phase 3 | Pending |
| HIST-04 | Phase 3 | Pending |
| STAT-01 | Phase 4 | Pending |
| STAT-02 | Phase 4 | Pending |
| STAT-03 | Phase 4 | Pending |
| STAT-04 | Phase 4 | Pending |
| LIVE-01 | Phase 5 | Pending |
| LIVE-02 | Phase 5 | Pending |
| LIVE-03 | Phase 5 | Pending |
| LIVE-04 | Phase 5 | Pending |
| QA-01 | Phase 1 | Pending |
| QA-02 | Phase 4 | Pending |
| QA-03 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 25 total
- Mapped to phases: 25
- Unmapped: 0

---
*Requirements defined: 2026-05-02*
*Last updated: 2026-05-02 after initial definition*
