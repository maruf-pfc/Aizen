# Aizen Ecosystem Documentation

Welcome to the documentation vault for **Aizen**, a massive, local-first productivity ecosystem.

## Architectural Mandates
1. **Feature-First Layered Architecture**: All application modules are isolated inside `lib/features/<module_name>/` and structured into distinct `domain`, `data`, and `presentation` layers.
2. **Local-First**: Complete reliance on fast, persistent local caches (e.g., SharedPreferences, databases) without cloud-service dependencies.
3. **Immutable State Management**: Clean segregation of side-effects using BLoCs/Cubits with immutable state objects.
4. **Performance Optimized**: Heavy operations and ticker loops are isolated at leaf widgets to maintain fluid frame rendering.
5. **Design & Typography**: Material 3 Expressive theme with Koinly-inspired Sleek Dark palette base, utilizing `Inter` typography and spring-physics page transitions.

---

## Active Modules
- **[Stopwatch Module](features/stopwatch.md) (v1.0.0)**: Our reference module showcasing high-precision centisecond ticking, background persistence, and custom tabular figure alignment.
- **[System Status / Device Info Module](features/device_info.md) (v1.2.0)**: System dashboard displaying deep hardware specs, real-time battery status streams, and custom segmented storage breakdowns.
- **[Quick Tasks (Todo) Module](features/todo.md) (v1.4.1)**: High-density minimalist task manager with local NLP parsing, manual clock time selection fallbacks, slide gestures, and inline task editing dialogs.
- **[Unified Navigation Workspace](features/navigation_hub.md) (v1.4.2)**: Central drawer managing route filtering and flat category layouts with nested Scaffold support.
- **[Advanced Settings Hub](features/settings.md) (v1.4.0)**: Controls themes, permission diagnostics, cache compaction, and JSON imports/exports.
- **[Focus Guardian Engine](features/focus_guardian.md) (v1.4.0)**: Native Android overlay projection and background app blocking.
- **[Habit Builder Module](features/habit_builder.md) (v1.5.0)**: Habit streak and failure prevention engine with real-time ticking, level rankings, and relapse journaling bottom sheets.
- **[Scientific Calculator](features/calculator.md) (v1.4.2)**: Scientific calculator utilizing a single-pass recursive descent math parser, featuring DEG/RAD end-to-end integration, a shift state (2nd) for inverse/hyperbolic functions, and standard constants.
- **[Expense & Bill Tracker](features/expense_tracker.md) (v1.5.0)**: Natural language command-line expense logger with persistent recurring bills, local notification reminders, swipe actions, and Koinly-inspired category analytics.
- **[Clipboard Vault](features/clipboard_vault.md) (v1.5.0)**: Heuristic clipboard content classifier and localized secure text archive.
- **[Time Blocker / Day Planner](features/time_blocker.md) (v1.5.0)**: A interactive 24-hour visual grid planner showing elapsed block progress and completed checkmarks.

---

## Pipeline Operations
The project uses GitHub Actions for continuous validation:
- Runs static analysis and checks for linter issues.
- Executes all unit and widget tests.
- Builds production web assets and multiple Android APK profiles (Universal and split ARM64/ARM32).
- Automatically pushes Git version tags and creates GitHub Releases upon pushing to `main`.
