# Phase 1: Data Integrity Foundation - Verification

## Phase 1 Verification Matrix

| Requirement | Decision IDs | Static Check | Runtime or Manual Check | Status |
|-------------|--------------|--------------|--------------------------|--------|
| REL-01 | D-11, D-12, D-13 | Confirm `TimerViewModel` restores `state.goal`, restores `state.danger`, saves threshold changes, and clamps `danger < goal`. | Settings persistence manual QA. | Pending |
| REL-02 | D-01, D-02, D-03, D-04, D-05 | Confirm Settings and Home long-press picker both use `AppConfig.Timer.reminderOptions`. | Reminder option parity manual QA. | Pending |
| REL-03 | D-06, D-08 | Confirm midnight rollover no longer inserts a split session or moves `currentSessionStart`; confirm `elapsedToday` resets visible progress. | Active timer across midnight manual QA. | Pending |
| REL-04 | D-07, D-09, D-10 | Confirm `SessionDayAllocator` is used for daily totals, streaks, and chart data. | Manual cross-midnight session edit QA. | Pending |
| QA-01 | D-14, D-15, D-16 | Confirm this artifact records static checks, build/test outcome, and manual QA scenarios. | Complete the verification checklist before Phase 1 close. | Pending |
