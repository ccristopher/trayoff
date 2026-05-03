# Phase 1: Data Integrity Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-05-02
**Phase:** 1-Data Integrity Foundation
**Areas discussed:** Reminder options, Midnight sessions

---

## Reminder Options

### Canonical reminder set

| Option | Description | Selected |
|--------|-------------|----------|
| `0, 15, 20, 30, 60` | Clean and already mostly product-like. | yes |
| `0, 5, 10, 15, 20, 30, 60` | More flexible, but a little busier. | |
| `0, 1, 15, 20, 30, 60` | Keep 1 minute for quick reminders/testing. | |
| Something else | User provides exact list. | |

**User's choice:** `0, 15, 20, 30, 60`  
**Notes:** Current code differs between Settings and Home; planner should unify both controls around this set.

### New-install default

| Option | Description | Selected |
|--------|-------------|----------|
| `0 minutes` | Reminders off by default; least pushy. | yes |
| `15 minutes` | Gently helpful by default. | |
| `20 minutes` | Matches the current habit vibe. | |
| Something else | User provides default. | |

**User's choice:** `0 minutes`  
**Notes:** Reminder notifications should be opt-in.

### Reminder entry points

| Option | Description | Selected |
|--------|-------------|----------|
| Settings + Home long-press | Keep both entry points, using the same options. | yes |
| Settings only | Simpler, less hidden behavior. | |
| Home only | Faster during timer use, but less discoverable. | |
| You decide | Agent chooses behavior. | |

**User's choice:** Settings + Home long-press  
**Notes:** Keep the existing two-entry-point product shape but remove drift.

### Active countdown behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Next session only | Current reminder keeps running; new value applies next time. | yes |
| Restart current reminder | Immediately reschedule countdown from now using the new value. | |
| Ask/confirm in UI | More explicit, but adds interaction weight. | |
| You decide | Agent chooses behavior. | |

**User's choice:** Next session only  
**Notes:** Avoid surprising changes to an in-flight countdown.

---

## Midnight Sessions

### History display

| Option | Description | Selected |
|--------|-------------|----------|
| One continuous session | Cleaner log; stats split duration behind the scenes. | yes |
| Two split sessions | One ending at midnight, one starting at midnight; explicit but noisier. | |
| One session with a spans-midnight label | Visible edge-case handling, but more UI work. | |
| You decide | Agent chooses behavior. | |

**User's choice:** One continuous session  
**Notes:** User-facing log stays simple; internal math must still split day totals correctly.

### Home display after midnight

| Option | Description | Selected |
|--------|-------------|----------|
| New day total only | Reset visible daily progress at midnight while the session continues. | yes |
| Full continuous session time | Keep counting the entire active session, even across days. | |
| Both | Show today's total plus a smaller continuous-session note. | |
| You decide | Agent chooses behavior. | user selected |

**User's choice:** You decide  
**Agent decision:** New day total only  
**Notes:** Daily goal/danger thresholds are daily habit boundaries.

### Manual cross-midnight edits

| Option | Description | Selected |
|--------|-------------|----------|
| Allow cross-midnight edits | Keep current date+time editor; stats split duration correctly. | yes |
| Prevent cross-midnight edits | Simpler logic, but less honest if someone left it out overnight. | |
| Warn but allow | More explicit, but adds UI weight. | |
| You decide | Agent chooses behavior. | user selected |

**User's choice:** You decide  
**Agent decision:** Allow cross-midnight edits  
**Notes:** Matches the current editor shape and keeps the session log honest.

### Historical daily totals

| Option | Description | Selected |
|--------|-------------|----------|
| Split by actual minutes per day | 11:50 PM to 12:10 AM counts 10 min each day. | yes |
| Count on start day | Simpler, but known-bug behavior. | |
| Count on end day | Simple, but can make previous day look wrong. | |
| You decide | Agent chooses behavior. | user selected |

**User's choice:** You decide  
**Agent decision:** Split by actual minutes per day  
**Notes:** This is the most correct behavior for history, streaks, and future stats.

---

## the agent's Discretion

- Settings behavior: persist goal/danger immediately, apply changes to current display state, and keep danger greater than or equal to goal.
- Verification confidence: prefer focused automated tests if cleanly possible; otherwise document manual QA honestly when local Xcode tooling is unavailable.
- Internal allocation helper shape: open to planner/implementer judgment as long as continuous logs and per-day split math are preserved.

## Deferred Ideas

None.
