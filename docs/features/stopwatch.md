# Aizen Stopwatch Module Specification (v1.0.0)

The **Stopwatch Module** is a high-precision, low-overhead, local-first stopwatch implementation. It serves as the reference implementation for UI and data patterns in the Aizen ecosystem.

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
- **Responsive Layout**:
  - **Narrow (<720px)**: Single column card stack.
  - **Wide ($\ge 720$px)**: Horizontal split screen.

---

## 2. Directory Layout (Feature-First Layered)
The files are grouped strictly by layer inside `lib/features/stopwatch/`:

- **Domain Layer**: Defines core business logic structures, completely free from external dependencies:
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

### State Survival Across App Restarts
To ensure zero background CPU overhead while the app is closed, the stopwatch calculates time elapsed based on system clock timestamps:
1. When starting/resuming, we capture the current date-time ($T_{\text{start}}$) and persist it along with the accumulated duration ($D_{\text{accumulated}}$).
2. When the app is closed, the stopwatch does not run active threads.
3. Upon restarting, the database loads the state. If `isRunning` is true, the current elapsed time is computed as:
   $$D_{\text{current}} = D_{\text{accumulated}} + (\text{DateTime.now()} - T_{\text{start}})$$
4. The local UI ticker is restarted using $D_{\text{current}}$ as its baseline.

### Local UI Ticker Optimization
To avoid rebuilding the entire page widget tree 60 times a second:
1. The BLoC only emits state changes for major action transitions (Start, Pause, Reset, Lap).
2. `StopwatchTimerDisplay` uses a leaf-level Flutter `Ticker` (via `SingleTickerProviderStateMixin`) that executes every frame.
3. The ticker triggers a local `setState()` only inside `StopwatchTimerDisplay`, updating the time rendering independently from the parent tree.
4. Tabular Figures (`FontFeature.tabularFigures()`) are applied to the textual stylesheet to force uniform digit widths, eliminating layout jitter.

---

## 4. Test Specifications
The module is protected by three test suites located in `test/`:
- **Domain Use Cases**: Tests repository stub interactions.
- **BLoC States**: Tests state flow on event triggers (e.g., matching expected values on Start, checking accumulator on Pause).
- **Widget Layouts**: Tests core widgets and ensures no layout overflows happen on small or wide screens.
