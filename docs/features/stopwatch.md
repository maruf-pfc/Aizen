# Aizen Stopwatch Module Specification (v1.5.0)

The **Stopwatch Module** is a high-precision, low-overhead, local-first stopwatch implementation. It features cross-platform capabilities including native background execution and lock-screen interactive notification tray.

---

## 1. Specifications & Features
- **Precision**: Centisecond (1/100th of a second) display resolution.
- **Controls**: Contextual actions matching the current execution phase:
  - **Initial**: `Start`
  - **Running**: `Pause` / `Lap`
  - **Paused**: `Resume` / `Reset`
- **Lap Table**: Scrollable table showing lap splits (duration) and overall time.
- **Lap Analytics**: Dynamically identifies and highlights the fastest lap in mint green and the slowest lap in coral red when $\ge 2$ laps are recorded.
- **Background Persistence**: Current timer status and recorded laps survive application close, termination, or system reboots.
- **Persistent Android Notification Bar Wrapper**: Displays a persistent lock screen notification.
  - Tapping **Pause/Resume** or **Lap** directly inside the notification tray updates the stopwatch state and registers laps without opening the main application.
  - Keeps the counting stopwatch state updated dynamically in real-time utilizing the system Chronometer without consuming extra CPU/battery.
- **Responsive Layout**:
  - **Narrow (<720px)**: Single column card stack.
  - **Wide ($\ge 720$px)**: Horizontal split screen.

---

## 2. Directory Layout (Feature-First Layered)
The files are grouped strictly by layer inside `lib/features/stopwatch/`:

- **Domain Layer**: Defines core business logic structures:
  - `entities/lap.dart`: Immutable definition of a lap split.
  - `entities/stopwatch_state.dart`: Immutable definition of the running parameters.
  - `repositories/stopwatch_repository.dart`: Data retrieval contracts.
  - `usecases/`: Action-specific operations (load/save/clear).
- **Data Layer**: Concrete data mapping and local storage accessors:
  - `models/lap_model.dart` / `stopwatch_state_model.dart`: JSON serialization and entity extensions.
  - `datasources/stopwatch_local_data_source.dart`: Raw `SharedPreferences` read/write access.
  - `repositories/stopwatch_repository_impl.dart`: Repository interface implementation catching errors.
- **Presentation Layer**: UI and state management:
  - `bloc/`: `StopwatchBloc`, `StopwatchEvent`, and `StopwatchState` for immutable state flow.
  - `widgets/stopwatch_timer_display.dart`: Ticker-driven display leaf widget.
  - `widgets/control_buttons.dart`: Contextual action buttons.
  - `widgets/lap_list_panel.dart`: High-density lap scroll list.
  - `pages/stopwatch_page.dart`: Page orchestrator with responsive layout boundaries.

---

## 3. Key Design Patterns

### State Survival Across App Restarts & Native Sync
To ensure zero background CPU overhead while the app is closed, the stopwatch calculates time elapsed based on system clock timestamps:
1. When starting/resuming, we capture the current date-time ($T_{\text{start}}$) and persist it along with the accumulated duration ($D_{\text{accumulated}}$).
2. The native Android Service (`StopwatchService.kt`) reads/writes directly to the Shared Preferences database file (`FlutterSharedPreferences.xml`) using the identical schema, allowing independent execution.
3. When the user interacts with the lock-screen notification tray actions, the service modifies the local preference files and fires a local Method Channel event to the active Flutter Activity if it's currently in memory, triggering a real-time UI refresh.

### Local UI Ticker Optimization
To avoid rebuilding the entire page widget tree 60 times a second:
1. The BLoC only emits state changes for major action transitions (Start, Pause, Reset, Lap).
2. `StopwatchTimerDisplay` uses a leaf-level Flutter `Ticker` (via `SingleTickerProviderStateMixin`) that executes every frame.
3. The ticker triggers a local `setState()` only inside `StopwatchTimerDisplay`, updating the time rendering independently from the parent tree.
