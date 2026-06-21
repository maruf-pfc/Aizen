# Aizen Ecosystem Documentation

Welcome to the documentation vault for **Aizen**, a massive, local-first productivity ecosystem.

## Architectural Mandates
1. **Feature-First Layered Architecture**: All application modules are isolated inside `lib/features/<module_name>/` and structured into distinct `domain`, `data`, and `presentation` layers.
2. **Local-First**: Complete reliance on fast, persistent local caches (e.g., SharedPreferences, databases) without cloud-service dependencies.
3. **Immutable State Management**: Clean segregation of side-effects using BLoCs/Cubits with immutable state objects.
4. **Performance Optimized**: Heavy operations and ticker loops are isolated at leaf widgets to maintain fluid frame rendering.
5. **Design & Typography**: AMOLED black theme with Material 3 details, utilizing `Lexend` typography for readability and the custom brand emblem launcher icon.

---

## Active Modules
- **[Stopwatch Module](features/stopwatch.md) (v1.0.0)**: Our reference module showcasing high-precision centisecond ticking, background persistence, and custom tabular figure alignment.
- **[Device Info Module](features/device_info.md) (v1.2.0)**: System dashboard displaying deep hardware specs, real-time battery status streams, and custom segmented storage breakdowns.

---

## Pipeline Operations
The project uses GitHub Actions for continuous validation:
- Runs static analysis and checks for linter issues.
- Executes all unit and widget tests.
- Builds production web assets and multiple Android APK profiles (Universal and split ARM64/ARM32).
- Automatically pushes Git version tags and creates GitHub Releases upon pushing to `main`.
