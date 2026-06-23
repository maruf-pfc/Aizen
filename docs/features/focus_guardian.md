# Targeted App Blocker & Focus Guardian (Version 1.5.0)

The Focus Guardian system controls background application blocking using native Android code and custom platform channels.

## Implementation Structure

### 1. Android Native Engine
- **`FocusBlockerService.kt`**:
  - Implements a foreground service running a `TimerTask` loop checked every 500ms.
  - Queries active packages via `UsageStatsManager`.
  - Projects a pure AMOLED black overlay via `WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY` when a blacklisted package resides in the foreground.
  - **Escalating Friction Lockout**: Rather than an instant absolute hard lockout, the overlay features an interactive **HOLD TO BYPASS (5s)** gesture. If the user touches and holds the bypass button, a progress bar fills up over 5 seconds. If held continuously, the overlay is dismissed and the foreground app is whitelisted/bypassed for 10 minutes. Any premature release resets the progress bar.
  - **60-Minute Emergency Auto-Unlock**: To prevent permanent lockout in case of state crashes, the blocker monitors overlay duration. If the overlay is active for more than 60 minutes, it automatically executes a failsafe reset.
  - **System Telemetry & Focus Engine Safety**: Monitors system statuses via a dynamic BroadcastReceiver. If the device battery level drops below 15% or the temperature crosses a high thermal threshold (> 45°C), the service triggers an emergency save state backup in Shared Preferences, protecting session progress from OS-level background service termination.
  - **Failsafe System**: If any state crashes, platform channel drops, or overlay drawing fails, it triggers an instant unblocking safety reset. This reset instantly clears the active blacklist packages list to restore full device access to the user and displays a Toast notification for safety.
- **`MainActivity.kt`**:
  - Sets up the `com.aizen.app/hardware_bridge` method channel.
  - Handles installed package query checks, permission checks (`SYSTEM_ALERT_WINDOW`, `PACKAGE_USAGE_STATS`), and initiates/stops background monitoring services dynamically.

### 2. Flutter Platform Bridge
- **`FocusBridgeService`**:
  - Encapsulates `MethodChannel` interactions.
  - Implements a `WidgetsBindingObserver` to re-poll state permissions automatically when resuming activity after the user returns from platform settings screens.
