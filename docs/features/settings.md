# Advanced Settings Hub Module (Version 1.4.0)

The Advanced Settings Hub manages global theme preferences, local database health commands, and system-level capability checks.

## Features
- **Theme Engine**: Switches between AMOLED Black, Dark Mode, and Light Mode theme profiles.
- **Local Database Maintenance**:
  - **Cache Compaction**: Sweeps temporary key-value structures.
  - **Database Optimization**: Compacts local storage configurations.
  - **Export JSON Backup**: Serializes local configurations to copyable JSON.
  - **Import JSON Backup**: Restores configuration profiles from JSON backup payloads.
- **Permission Diagnostics**: Real-time checking and visual status toggling for Usage Stats and System Overlay permissions, including direct links to launch platform settings panels.

## Architecture

### 1. Domain Layer
- **Entities**:
  - `GlobalSettings`: Configuration structure holding theme and permission state.
- **failures**:
  - `SettingsFailure`
  - `CacheClearFailure`
  - `DatabaseOptimizationFailure`
  - `ExportImportFailure`

### 2. Data Layer
- **Data Source**: `SettingsLocalDataSource` (uses `SharedPreferences` to persist configurations and backup JSON payloads).

### 3. State Management (BLoC)
- `SettingsBloc` handles settings loading, theme mutations, permission diagnosis, cache clearing, DB compaction, and JSON export/import.
