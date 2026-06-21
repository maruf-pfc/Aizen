# Targeted App Blocker & Focus Guardian (Version 1.4.0)

The Focus Guardian system controls background application blocking using native Android code and custom platform channels.

## Implementation Structure

### 1. Android Native Engine
- **`FocusBlockerService.kt`**:
  - Implements a foreground service running a `TimerTask` loop checked every 500ms.
  - Queries active packages via `UsageStatsManager`.
  - Projects a pure AMOLED black overlay via `WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY` when a blacklisted package resides in the foreground.
  - **Failsafe System**: Monitors active duration; automatically calls `removeView()` on the window manager if the overlay displays continuously for 60 minutes, ensuring system recovery from crashes or drops.
- **`MainActivity.kt`**:
  - Sets up the `com.aizen.app/hardware_bridge` method channel.
  - Handles installed package query checks, permission checks (`SYSTEM_ALERT_WINDOW`, `PACKAGE_USAGE_STATS`), and initiates/stops background monitoring services dynamically.

### 2. Flutter Platform Bridge
- **`FocusBridgeService`**:
  - Encapsulates `MethodChannel` interactions.
  - Implements a `WidgetsBindingObserver` to re-poll state permissions automatically when resuming activity after the user returns from platform settings screens.
