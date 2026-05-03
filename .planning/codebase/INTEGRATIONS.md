---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: tech
---

# External Integrations

**Analysis Date:** 2026-05-02

## APIs & External Services

**Apple Platform Services:**
- Local Notifications - Used for retainer reminder alerts.
  - SDK/Client: `UserNotifications`
  - Auth: User-granted notification permission requested in `Retainer Tracker/Services/NotificationService.swift`
  - Implementation: `UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])`, `UNNotificationRequest`, and `UNTimeIntervalNotificationTrigger` in `Retainer Tracker/Services/NotificationService.swift`
- Live Activities - Used for Lock Screen and Dynamic Island timer state.
  - SDK/Client: `ActivityKit`
  - Auth: iOS Live Activities entitlement/runtime capability; app enables `INFOPLIST_KEY_NSSupportsLiveActivities = YES` in `TrayOff.xcodeproj/project.pbxproj`
  - Implementation: `Activity.request`, `activity.update`, and `activity.end` in `Retainer Tracker/Services/LiveActivityManager.swift`; UI configuration in `RetainerWidget/RetainerActivityWidget.swift`
- Home Screen Widgets - Used for small widget display of timer state.
  - SDK/Client: `WidgetKit`
  - Auth: Widget extension target `RetainerWidgetExtension` with `NSExtensionPointIdentifier = com.apple.widgetkit-extension` in `RetainerWidget/Info.plist`
  - Implementation: `StaticConfiguration`, `TimelineProvider`, and `Timeline` in `RetainerWidget/RetainerWidget.swift`; timeline refresh triggered by `WidgetCenter.shared.reloadAllTimelines()` in `Retainer Tracker/ViewModels/TimerViewModel.swift`
- App Groups - Used to share encoded timer state between the app and widget extension.
  - SDK/Client: `Foundation.UserDefaults(suiteName:)`
  - Auth: App group entitlement `group.com.TrayOff.shared` in `Retainer Tracker/Retainer Tracker.entitlements` and `RetainerWidgetExtension.entitlements`
  - Implementation: Timer state written in `Retainer Tracker/Services/PersistenceService.swift` and read in `RetainerWidget/RetainerWidget.swift`

**Network APIs:**
- Not detected.
  - SDK/Client: No `URLSession`, HTTP endpoint, REST, GraphQL, Firebase, Supabase, Stripe, AWS, analytics, or telemetry SDK usage detected in Swift sources.
  - Auth: Not applicable.

## Data Storage

**Databases:**
- SwiftData local persistent store.
  - Connection: Local on-device SwiftData container; no remote database URL or env var.
  - Client: `SwiftData.ModelContainer`, `ModelContext`, `FetchDescriptor`, and `@Model`.
  - Model: `Retainer Tracker/Models/Session.swift`.
  - Container setup: `Retainer Tracker/App/TrayOff.swift` creates `Schema([Session.self])`, `ModelConfiguration(schema:isStoredInMemoryOnly: false)`, and `ModelContainer`.
  - CRUD access: `Retainer Tracker/Services/SessionManager.swift` inserts, fetches, updates, deletes, and bulk-deletes `Session` records through `ModelContext`.

**File Storage:**
- Local app container only.
  - SwiftData owns the session store created by `ModelContainer` in `Retainer Tracker/App/TrayOff.swift`.
  - No explicit `FileManager` storage, document storage, iCloud Drive, S3, or blob storage detected.

**Key-Value Storage:**
- Standard `UserDefaults` stores user preferences such as `selectedReminder`, `showGoalStatus`, and `hasSeenOnboarding` in `Retainer Tracker/Services/ReminderManager.swift`, `Retainer Tracker/ViewModels/TimerViewModel.swift`, and `Retainer Tracker/Views/ContentView.swift`.
- App Group `UserDefaults` stores encoded `TimerState` under key `timerState` in `Retainer Tracker/Services/PersistenceService.swift`; widget reads the same key in `RetainerWidget/RetainerWidget.swift`.
- `TimerPersistenceService` migrates existing `timerState` data from standard defaults to shared defaults in `Retainer Tracker/Services/PersistenceService.swift`.

**Caching:**
- WidgetKit timeline caching.
  - Timeline provider returns one entry and refreshes after 15 minutes in `RetainerWidget/RetainerWidget.swift`.
  - App requests immediate refresh with `WidgetCenter.shared.reloadAllTimelines()` after timer state saves in `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- No Redis, Memcached, HTTP cache, or custom disk cache detected.

## Authentication & Identity

**Auth Provider:**
- Not detected.
  - Implementation: No sign-in UI, OAuth, Sign in with Apple, Firebase Auth, Auth0, Clerk, keychain credential storage, or account model detected.

**Authorization/Permissions:**
- Notification permission is requested by `NotificationService.requestPermissions()` in `Retainer Tracker/Services/NotificationService.swift`.
- Live Activities rely on the iOS runtime and `INFOPLIST_KEY_NSSupportsLiveActivities = YES` in `TrayOff.xcodeproj/project.pbxproj`.
- App Group data sharing relies on matching `group.com.TrayOff.shared` entitlements in `Retainer Tracker/Retainer Tracker.entitlements` and `RetainerWidgetExtension.entitlements`.

## Monitoring & Observability

**Error Tracking:**
- None detected.
  - No Sentry, Firebase Crashlytics, AppCenter, Datadog, OpenTelemetry, or custom remote error reporting imports/configuration detected.

**Logs:**
- Console output only.
  - `NotificationService.scheduleReminder(minutes:)` prints scheduling failures in `Retainer Tracker/Services/NotificationService.swift`.
  - Several persistence and SwiftData failure paths swallow errors or return fallback values in `Retainer Tracker/Services/PersistenceService.swift`, `Retainer Tracker/Services/SessionManager.swift`, and `Retainer Tracker/App/TrayOff.swift`.

## CI/CD & Deployment

**Hosting:**
- Apple App Store/TestFlight style distribution is implied by the iOS app target, automatic signing, and bundle identifiers in `TrayOff.xcodeproj/project.pbxproj`.
- No Vercel, server hosting, backend deployment, container, or cloud infrastructure configuration detected.

**CI Pipeline:**
- None detected.
  - No `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/config.yml`, `Fastfile`, or other CI/CD workflow files detected.

## Environment Configuration

**Required env vars:**
- None detected.
  - Build and runtime configuration use Xcode build settings, property lists, entitlements, and Swift constants rather than process environment variables.

**Secrets location:**
- No `.env`, `.env.*`, credential, certificate, private key, or package-auth files detected at repo depth 3.
- Code signing is configured by Xcode project settings with `CODE_SIGN_STYLE = Automatic`, `DEVELOPMENT_TEAM = QXMDCMDF8D`, and bundle identifiers in `TrayOff.xcodeproj/project.pbxproj`.

**Configuration files:**
- `TrayOff.xcodeproj/project.pbxproj` - Targets, signing, deployment targets, generated Info.plist keys, embedded extension, and framework references.
- `Retainer-Tracker-Info.plist` - Main app Info.plist values and launch/orientation metadata.
- `RetainerWidget/Info.plist` - Widget extension point declaration.
- `Retainer Tracker/Retainer Tracker.entitlements` - Main app App Group entitlement.
- `RetainerWidgetExtension.entitlements` - Widget extension App Group entitlement.
- `Retainer Tracker/Utils/AppConfig.swift` - App defaults for timer thresholds, update interval, persistence key names, UI constants, and animation durations.

## Webhooks & Callbacks

**Incoming:**
- None detected.
  - The app has no server endpoints, URL scheme handlers, universal link handlers, push notification device-token registration, or webhook receivers.

**Outgoing:**
- None detected.
  - The app does not call external HTTP APIs or emit webhook callbacks.

**System callbacks:**
- SwiftUI scene phase callbacks drive timer pause/resume and state persistence in `Retainer Tracker/App/TrayOff.swift`.
- Widget timeline callbacks are implemented by `Provider.getSnapshot` and `Provider.getTimeline` in `RetainerWidget/RetainerWidget.swift`.
- Live Activity callbacks are represented through ActivityKit state updates from `Retainer Tracker/Services/LiveActivityManager.swift` to `RetainerWidget/RetainerActivityWidget.swift`.

---

*Integration audit: 2026-05-02*
