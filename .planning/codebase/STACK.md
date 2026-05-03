---
last_mapped_commit: 40ff02953b853e1d642e4a3e9c8aa5631ffad0d6
mapped_at: 2026-05-02
focus: tech
---

# Technology Stack

**Analysis Date:** 2026-05-02

## Languages

**Primary:**
- Swift - Main application, widget extension, models, services, and views live under `Retainer Tracker/` and `RetainerWidget/`.
- Swift language mode 5.0 - Xcode build settings set `SWIFT_VERSION = 5.0` for `TrayOff` and `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`.
- Swift tools 5.3 - Swift Package Manager manifest declares `// swift-tools-version:5.3` in `Package.swift`.

**Secondary:**
- XML property lists - App, extension, and entitlement configuration in `Retainer-Tracker-Info.plist`, `RetainerWidget/Info.plist`, `Retainer Tracker/Retainer Tracker.entitlements`, and `RetainerWidgetExtension.entitlements`.
- JSON asset catalogs - Xcode-managed asset metadata under `Retainer Tracker/Assets.xcassets/`, `RetainerWidget/Assets.xcassets/`, and `TrayOff.icon/icon.json`.
- Markdown - Project documentation in `README.md`, `CONTRIBUTING.md`, and `LICENSE`.

## Runtime

**Environment:**
- iOS application runtime - Main target `TrayOff` builds an iPhone app with `SDKROOT = iphoneos`, `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`, and `TARGETED_DEVICE_FAMILY = 1` in `TrayOff.xcodeproj/project.pbxproj`.
- Widget extension runtime - Target `RetainerWidgetExtension` builds an app extension with `productType = "com.apple.product-type.app-extension"` and `NSExtensionPointIdentifier = com.apple.widgetkit-extension` in `TrayOff.xcodeproj/project.pbxproj` and `RetainerWidget/Info.plist`.
- Deployment target 26.0 for shipping targets - `IPHONEOS_DEPLOYMENT_TARGET = 26.0` is set on `TrayOff` and `RetainerWidgetExtension` target build configurations in `TrayOff.xcodeproj/project.pbxproj`.
- Project-level deployment target 18.2 - Project build configurations set `IPHONEOS_DEPLOYMENT_TARGET = 18.2` in `TrayOff.xcodeproj/project.pbxproj`; target-level settings override this for the app and widget.
- Source availability gates - App and widget entry points use `@available(iOS 26.0, *)` in `Retainer Tracker/App/TrayOff.swift`, `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerActivityWidget.swift`, and `RetainerWidget/RetainerWidgetBundle.swift`.
- Local CLI observed during mapping - `swift --version` reports Apple Swift 6.2.4; `xcodebuild` is unavailable because the active developer directory is Command Line Tools rather than a full Xcode app.

**Package Manager:**
- Swift Package Manager - `Package.swift` defines package `TrayOff`, product `TrayOff`, and target `TrayOff` with path `Retainer Tracker`.
- Lockfile: missing - No `Package.resolved` detected.
- External package dependencies: none - `Package.swift` has `dependencies: []` and target `dependencies: []`.

## Frameworks

**Core:**
- SwiftUI - Main UI framework imported by app views and components such as `Retainer Tracker/App/TrayOff.swift`, `Retainer Tracker/Views/HomeView.swift`, `Retainer Tracker/Views/StatsView.swift`, and `RetainerWidget/RetainerWidget.swift`.
- SwiftData - Local model persistence for `Session` via `@Model` in `Retainer Tracker/Models/Session.swift`, initialized in `Retainer Tracker/App/TrayOff.swift`, and used by `Retainer Tracker/Services/SessionManager.swift`.
- WidgetKit - Home screen widget and timeline reload support in `RetainerWidget/RetainerWidget.swift`, `RetainerWidget/RetainerWidgetBundle.swift`, and `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- ActivityKit - Live Activity attributes, manager, and Dynamic Island/Lock Screen widget UI in `Retainer Tracker/Models/RetainerActivityAttributes.swift`, `Retainer Tracker/Services/LiveActivityManager.swift`, and `RetainerWidget/RetainerActivityWidget.swift`.
- Combine - Observable timer and reminder state bindings in `Retainer Tracker/Services/TimerEngine.swift`, `Retainer Tracker/Services/ReminderManager.swift`, and `Retainer Tracker/ViewModels/TimerViewModel.swift`.
- Charts - Statistics visualization in `Retainer Tracker/Views/StatsView.swift`.
- UserNotifications - Local reminder permission requests, scheduling, and cancellation in `Retainer Tracker/Services/NotificationService.swift`.

**Testing:**
- XCTest target: Not detected.
- Swift Testing target: Not detected.
- Test files: Not detected. No `*.test.swift`, `*Tests.swift`, or `*.spec.swift` files are present.

**Build/Dev:**
- Xcode project - `TrayOff.xcodeproj/project.pbxproj` is the app build source of truth for targets, signing, entitlements, Info.plist generation, assets, deployment target, and embedded extension.
- SwiftPM manifest - `Package.swift` exposes the app sources as a library package named `TrayOff`; use it for package-level tooling only because the app/widget packaging is defined in `TrayOff.xcodeproj/project.pbxproj`.
- Xcode asset catalogs - App assets in `Retainer Tracker/Assets.xcassets/` and widget assets in `RetainerWidget/Assets.xcassets/`.
- Generated Info.plist settings - Build settings use `GENERATE_INFOPLIST_FILE = YES` while also pointing at `Retainer-Tracker-Info.plist` and `RetainerWidget/Info.plist`.

## Key Dependencies

**Critical:**
- Apple SDK frameworks - The application depends entirely on Apple platform frameworks declared through Swift imports and Xcode framework references in `TrayOff.xcodeproj/project.pbxproj`.
- SwiftData - Required for persisted session history; add new persisted domain models next to `Retainer Tracker/Models/Session.swift` and register them in the `Schema` created in `Retainer Tracker/App/TrayOff.swift`.
- WidgetKit + App Groups - Required for widget display of timer state; shared state is encoded in `Retainer Tracker/Services/PersistenceService.swift` and decoded in `RetainerWidget/RetainerWidget.swift`.
- ActivityKit - Required for Live Activities and Dynamic Island surfaces; activity state shape is defined in `Retainer Tracker/Models/RetainerActivityAttributes.swift`.
- UserNotifications - Required for local reminder alerts; scheduling is centralized in `Retainer Tracker/Services/NotificationService.swift`.

**Infrastructure:**
- Application Groups entitlement - `group.com.TrayOff.shared` is declared in both `Retainer Tracker/Retainer Tracker.entitlements` and `RetainerWidgetExtension.entitlements`.
- Automatic code signing - `CODE_SIGN_STYLE = Automatic` and `DEVELOPMENT_TEAM = QXMDCMDF8D` are set in `TrayOff.xcodeproj/project.pbxproj`.
- Bundle identifiers - Main app uses `com.cristopher.TrayOff`; widget extension uses `com.cristopher.TrayOff.Widget` in `TrayOff.xcodeproj/project.pbxproj`.
- App versioning - `MARKETING_VERSION = 1.1` and `CURRENT_PROJECT_VERSION = 1` are set in `TrayOff.xcodeproj/project.pbxproj`.

## Configuration

**Environment:**
- No `.env`, `.env.*`, credential, certificate, or package-auth files detected at repo depth 3.
- Runtime configuration is source-based through constants in `Retainer Tracker/Utils/AppConfig.swift`, persisted user preferences in `UserDefaults`, and Xcode build settings in `TrayOff.xcodeproj/project.pbxproj`.
- Timer state persistence key is `timerState` in `Retainer Tracker/Services/PersistenceService.swift`; widget reads the same key in `RetainerWidget/RetainerWidget.swift`.
- Shared app group suite is `group.com.TrayOff.shared` in `Retainer Tracker/Services/PersistenceService.swift`, `RetainerWidget/RetainerWidget.swift`, `Retainer Tracker/Retainer Tracker.entitlements`, and `RetainerWidgetExtension.entitlements`.

**Build:**
- App target: `TrayOff` in `TrayOff.xcodeproj/project.pbxproj`.
- Widget target: `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`.
- SwiftPM package: `Package.swift`.
- App Info.plist: `Retainer-Tracker-Info.plist`.
- Widget Info.plist: `RetainerWidget/Info.plist`.
- App entitlements: `Retainer Tracker/Retainer Tracker.entitlements`.
- Widget entitlements: `RetainerWidgetExtension.entitlements`.
- App icons and launch imagery: `Retainer Tracker/Assets.xcassets/`, `RetainerWidget/Assets.xcassets/`, and `TrayOff.icon/`.

## Platform Requirements

**Development:**
- Use a full Xcode installation to build and inspect schemes; the current active developer directory exposes Command Line Tools only, so `xcodebuild -version` and `xcodebuild -list -project TrayOff.xcodeproj` fail in this shell.
- Open `TrayOff.xcodeproj` for app development because it defines the app target, widget extension target, signing, entitlements, resources, and embedded extension.
- Keep new app code under `Retainer Tracker/` and new widget code under `RetainerWidget/` so the Xcode file system synchronized groups include the files without manual project edits.
- Preserve SwiftUI preview-only model containers in view files such as `Retainer Tracker/Views/ContentView.swift`, `Retainer Tracker/Views/HomeView.swift`, and `Retainer Tracker/Views/StatsView.swift` when adding UI previews.

**Production:**
- Deployment target is iOS 26.0 for both the `TrayOff` app and `RetainerWidgetExtension` in `TrayOff.xcodeproj/project.pbxproj`.
- Distribution uses Apple code signing and bundle IDs configured in `TrayOff.xcodeproj/project.pbxproj`.
- No CI/CD, Fastlane, or hosted deployment configuration detected.

---

*Stack analysis: 2026-05-02*
