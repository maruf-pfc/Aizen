# Habit Builder Module (v1.5.0)

The **Habit Builder** module is a local-first, low-RAM habit-tracking and streak engine designed to prevent habit failure and assist users in self-discipline.

---

## 🚀 Core Specifications

### 1. Dual Tracking Modes
* **Automatic Clean Time Counter**: Real-time ticker counting elapsed days, hours, minutes, and seconds since the last reset. Best for tracking clean streaks (e.g. caffeine, sugar, social media fasts).
* **Manual Daily Check-in**: Daily manual tick checklist displaying a 365-day contribution drift map. Best for positive habit building (e.g. reading, exercising).

### 2. Gamified User Levels
Includes 8 levels based on active streak days:
1. **Recruit** (Lvl 1): 0 days
2. **Apprentice** (Lvl 2): 1-2 days
3. **Sentinel** (Lvl 3): 3-6 days
4. **Guardian** (Lvl 4): 7-13 days
5. **Overlord** (Lvl 5): 14-29 days
6. **Conqueror** (Lvl 6): 30-59 days
7. **Immortal** (Lvl 7): 60-89 days
8. **Iron Will** (Lvl 8): 90+ days

Each card displays a progress bar indicating how close the user is to the next level.

### 3. Failure Analysis & Relapse Journaling
* **Slide-Up Bottom Sheet**: Triggers a premium Material 3 bottom sheet for relapse logging.
* **Metadata Analysis**: Logs root cause category (Stress, Fatigue, Boredom, etc.), trigger context, stress/anxiety level (1-5), and post-relapse reflection notes.
* **Failure Ledger**: Renders a chronicled timeline history of past attempts to identify behavior patterns.

### 4. Post-Relapse Behavioral Triage Flow
* When the user reports a habit relapse (by submitting a relapse log), they are immediately transitioned into a context-sensitive **4-7-8 Breathing Triage Visualizer** directly within the sheet.
* Gathers the logged stress level and suggests tailored cycles:
  - **Stress level >= 4**: 4 cycles of 4-7-8 breathing.
  - **Stress level < 4**: 2 cycles of 4-7-8 breathing.
* The visualizer features a lung-expansion simulator (scaling circle matching phase timing: 4s inhale, 7s hold, 8s exhale) with context-colored accents (Cyan, Purple, Amber) and step instructions to down-regulate the nervous system instantly.

### 5. Android Home-Screen Widget Integration
* Uses Flutter's AppWidget Provider bridge (`com.aizen.app/hardware_bridge`) to trigger updates on the native Android system launcher.
* Displays current habit streak names and days clean directly on the home screen.

---

## 🛠️ Tech Stack & Optimization
* **BLoC State Management**: Managed via `HabitBloc`, `HabitEvent`, and `HabitState`.
* **Low-RAM & Battery Optimization**: The real-time ticking duration in `HabitCard` uses a localized widget-level `Timer` that only runs when the card is mounted and visible, keeping CPU cycles to a minimum.
* **Local Storage**: Persisted locally via `SharedPreferences` in JSON format.
