# Aizen Ecosystem ⚡

> **Current Version: v1.5.0** — High-aura ecosystem release: cross-module
> intelligence, persistent background stopwatch service, escalating friction
> lockout, and behavioral relapse triage flow.

Aizen is a premium, local-first productivity ecosystem for Android. It features
a Koinly-inspired Sleek Dark canvas (`0xFF061012`), Material 3 Expressive design
language (Inter typography, spring-physics page transitions, pill-shaped
navigation indicators), native Android scroll physics, tactile haptic feedback
on every interactive surface, and a feature-first clean architecture.

---

## 🛠️ Technology Stack

| Concern | Technology |
|---|---|
| Framework | Flutter 3.35.1 / Dart 3.9.0 |
| State management | `flutter_bloc` + `equatable` |
| Typography | Google Fonts — **Inter** (M3 type scale) |
| Persistence | `shared_preferences` |
| Notifications | `flutter_local_notifications` |
| Testing | `flutter_test`, `bloc_test`, `mocktail` |
| CI/CD | GitHub Actions — lint, test, APK build, release |

---

## 📂 Feature Architecture

Aizen follows a **Feature-First Layered Architecture**. Each module lives in
`lib/features/<module_name>/` with three strict layers:

1. **Domain** — Entities, repository interfaces, use cases (pure Dart, zero Flutter deps)
2. **Data** — Models, local data sources, repository implementations
3. **Presentation** — BLoCs/events/states, widgets, pages

Full documentation index: [docs/README.md](docs/README.md)

---

## 🎨 Design System

### M3 Expressive Theme (`lib/core/theme/aizen_theme.dart`)
- **Sleek Dark** canvas (`#061012`) with custom surface elevation ramp
- **Color roles**: `primaryPurple` (Sleek Cyan `#00C7D8`) · `accentGreen` · `accentCyan` · `accentAmber` · `accentRed`
- **Shape tokens**: `shapeXs=6` `shapeSm=10` `shapeMd=16` `shapeLg=24` `shapeXl=32` `shapeFull=100`
- **Spring-physics page transitions** — fade + 3% slide-up + scale from 0.97 on `easeOutCubic`
- **Motion constants**: `motionShort=200ms` `motionMedium=350ms` `motionLong=500ms`
- **`AizenBreakpoints`** — adaptive horizontal padding and max content width across compact/medium/expanded layouts
- **`AizenPressable`** — spring-scale (96%) press animation widget

### Navigation Bar (Dashboard)
Custom `_AizenNavBar` with animated pill indicators, spring icon scale, and
directional slide-fade body transitions between tabs.

---

## 🚀 Getting Started

### Local Development

```bash
# Clone
git clone https://github.com/blackstart-labs/Aizen.git
cd Aizen

# Install dependencies
flutter pub get

# Run static analysis (must be clean)
flutter analyze

# Run all tests
flutter test

# Launch on device
flutter run
```

### CI/CD Pipeline

GitHub Actions (`.github/workflows/`) runs on every push to `main`:
1. `flutter analyze` — static analysis (zero warnings policy)
2. `flutter test` — full unit + widget + integration suite
3. APK build — universal + split ARM64/ARM32 profiles
4. GitHub Release — auto-tag and release on `main` push

---

## 📦 Active Modules

### 1. Stopwatch (v1.0.0)
- Centisecond-precision ticker with background persistence via system clock offsets
- Lap table with fastest (green) / slowest (red) highlight
- Docs: [docs/features/stopwatch.md](docs/features/stopwatch.md)

### 2. System Status — Device Info (v1.2.0)
- Deep hardware: CPU cores, RAM, model, kernel architecture
- Real-time battery stream (charge %, health, temperature)
- Multi-segment storage bar (used / free in GB)
- Docs: [docs/features/device_info.md](docs/features/device_info.md)

### 3. Quick Tasks — Todo (v1.4.1)
- Inline NLP parser: priorities (`!!1`–`!!4`), tags (`#tag`), natural dates
- Slide-right to complete, slide-left to delete
- Inline M3 edit dialogs, reactive sorting
- Docs: [docs/features/todo.md](docs/features/todo.md)

### 4. Navigation Hub + Settings (v1.4.2)
- Search-enabled drawer, flat lazy `ListView.builder` (O(1) layout)
- No category header clutter — clean flat module list
- Diagnostics panel, cache compaction, JSON export/import
- Docs: [docs/features/navigation_hub.md](docs/features/navigation_hub.md)

### 5. Habit Builder (v1.5.0)
- Dual tracking: real-time streak counter + manual daily check-in
- 8 gamified levels (Recruit → Iron Will) with dynamic progress bars
- 365-day contribution grid + post-relapse micro-journaling
- Integrated **4-7-8 Breathing Triage Visualizer** to calm down post-relapse
- Android home-screen widget via MethodChannels
- Docs: [docs/features/habit_builder.md](docs/features/habit_builder.md)

### 6. Scientific Calculator (v1.5.0)
- Recursive-descent parser: zero regex, single-pass, low-RAM
- **DEG/RAD** mode wired end-to-end from UI → engine
- **Functions**: sin/cos/tan (with `tan(90°)` domain guard), asin/acos/atan,
  sinh/cosh/tanh, asinh/acosh/atanh, log/log2/ln/exp, sqrt/cbrt/sq/rec,
  abs/sign/fact/gcd/lcm/round/floor/ceil/trunc, pi/e/phi/tau
- **2nd shift row** for inverse/hyperbolic functions
- Memory (M+, M−, MR, MC), history tape (last 20)
- Full unit test suite: 90+ tests across DEG mode, RAD mode, domain errors

### 7. Expense & Bill Pay (v1.5.0)
- Command-driven entry: `50 #lunch`, `-20 #refund note`
- Persistent bill reminders with daily notifications
- Ledger + Analytics + Bills tabbed view, swipe-to-delete
- Koinly-inspired category spending breakdown and metrics
- Docs: [docs/features/expense_tracker.md](docs/features/expense_tracker.md)

### 8. Clipboard Vault (v1.5.0)
- Auto-classifies clipboard entries: Links / Snippets / Plain Text
- Single-pass heuristic classifier — zero Flutter dependencies
- Filter chips, swipe-to-delete, tap-to-copy
- Docs: [docs/features/clipboard_vault.md](docs/features/clipboard_vault.md)

### 9. Day Planner — Time Blocker (v1.5.0)
- 24-hour visual grid with hour-block claims
- Live elapsed progress indicator on active blocks
- Color palette, label editing, mark-complete, date navigation
- Docs: [docs/features/time_blocker.md](docs/features/time_blocker.md)

### 10. Focus Guardian (v1.5.0)
- Native Android overlay projection + background app blocking
- **Escalating Friction Lockout**: 5s continuous hold to bypass restricted apps
- **60-Min Emergency Failsafe**: Auto-unlock after 60 mins of overlay lock
- **System status telemetry integration**: Session auto-saved if battery < 15% or temp > 45C
- Docs: [docs/features/focus_guardian.md](docs/features/focus_guardian.md)

---

## 🧪 Test Coverage

| Area | Test file |
|---|---|
| Calculator engine (90+ cases) | `test/features/calculator/domain/engine/calculator_engine_test.dart` |
| Habit BLoC | `test/features/habit_tracker/presentation/bloc/habit_bloc_test.dart` |
| Navigation Drawer | `test/features/navigation_hub/presentation/widgets/navigation_hub_drawer_test.dart` |

Run all: `flutter test`

---

## 📝 Changelog

### v1.5.0 (current)
- **Scientific Calculator, Expense & Bill Pay, Clipboard Vault, 24-Hour Day Planner** — Added 4 brand-new major utility/productivity modules in a unified architecture.
- **Stopwatch background service** — Added native Android `StopwatchService` with interactive lock screen notification tray actions (Play, Pause, Lap).
- **Focus Guardian security loop** — Implemented Escalating Friction Lockout (5-second hold to bypass), 60-minute auto-unlock failsafe, and battery/thermal status auto-save protection.
- **Habit Tracker triage** — Added post-relapse modal behavior triage with visual 4-7-8 breathing countdown animation.
- **Cross-module symbiosis** — Connected Todo priority tasks to Time Blocker suggestions, and Expense Input bar with a mini Scientific Calculator bottom-sheet.
- **Bug Fixes** — Resolved decimal factorial integer overflows in `CalculatorEngine` and escaped dollar signs in Dart string interpolation fields.
- **Android Integration** — Added Habit Builder with streak engine, level progression, relapse journaling, and Android home-screen widget via MethodChannels.

### v1.4.2
- **CI** — resolved all `flutter analyze` warnings (unused imports, library names, deprecated members, async context gaps, curly-braces lint)
- **Theme** — upgraded to full M3 Expressive: Inter type scale, spring-physics page transitions, animated pill NavigationBar, shape token system, `AizenBreakpoints` responsive helpers, `AizenPressable` widget
- **Calculator** — complete scientific calculator rewrite: `degMode` parameter in engine, `tan(90°)` domain guard, 15+ new functions (`log2`, `fact`, `sq`, `rec`, `asinh`, `acosh`, `atanh`, `sign`, `gcd`, `lcm`, `trunc`, `atan2`), 2nd-shift UI row, full-grid layout
- **Naming** — "Kernel Profile & Telemetry" → "System Status"; "Willpower" → "Habit Builder"
- **Tests** — expanded calculator engine tests to 90+ cases covering DEG/RAD, new functions, and domain errors
- **Sidebar** — removed "Active Modules" and category headers

### v1.4.1
- Added Quick Tasks with inline NLP parser
- Unified Navigation Hub drawer with search and accordion categories
- Advanced Settings Hub

### v1.2.0
- Added Device Info / System Status module

### v1.0.0
- Initial release: Stopwatch module with centisecond precision and lap tracking
