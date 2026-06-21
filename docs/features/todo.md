# Quick Tasks (Todo) Module (Version 1.3.0)

The Quick Tasks module is a high-density, performance-optimized task management utility. It integrates inline Natural Language Processing (NLP) parsing to capture priorities, tags, and dates without leaving the keyboard.

## Features
- **Inline NLP Parser**: A pure Dart regex-based string parser that extracts priority (`!!1` to `!!4`), tags (`#tagname`), and due date/time parameters (`today`, `tomorrow`, `monday`, `at 5pm`, etc.) dynamically.
- **Minimalist Tiered Hierarchy**: Indented subtask lists nested beneath the parent task row with a clean vertical guide line.
- **AMOLED-First Aesthetics**: Visual design inspired by Bitwarden/Telegram dark UI layouts utilizing thin colored border accents to denote priority levels.
- **Slidable Rows**: Integrated `Dismissible` swipes (Left to delete, Right to mark as complete).
- **Reactive Sorting**: Instant sorting of task lists by priority, due date, or creation date, placing completed items at the bottom.

## Architecture

### 1. Domain Layer
- **Entities**:
  - `Task`: Main task model with priority, tags, subtasks, recurrence, and dates.
  - `Subtask`: Simple checkable items nested under a task.
  - `Tag`: Standard task labels.
  - `NlpParsedResult`: Intermediate parsing payload.
- **failures**:
  - `TodoDatabaseFailure`
  - `TodoNlpParsingFailure`
- **Repository Contract**: `TodoRepository`
- **Use Cases**:
  - `GetTasks`
  - `SaveTask`
  - `DeleteTask`
  - `ParseNlpInput`

### 2. Data Layer
- **Models**:
  - `TaskModel`: JSON-serializable wrapper extending `Task`.
  - `SubtaskModel`: JSON-serializable wrapper extending `Subtask`.
  - `TagModel`: JSON-serializable wrapper extending `Tag`.
- **Services**:
  - `NlpParserService`: Custom regex-based algorithmic parser (pure Dart, zero dependencies).
- **Data Source**: `TodoLocalDataSource` (uses `SharedPreferences` to serialize and store tasks).
- **Repository Implementation**: `TodoRepositoryImpl`

### 3. Presentation Layer
- **BLoC**: `TodoBloc` (reactive loading, toggles, updates, deletion, and priority sorting).
- **Widgets**:
  - `InlineNlpInput`: Interactive input field rendering real-time chip previews of tags, dates, and priorities as the user types.
  - `FilterBar`: Minimalist pill buttons to swap the reactive sorting scheme.
  - `TaskRow`: Compact row container with priority border flags.
  - `SubtaskList`: Indented list showing nested items.
- **Pages**:
  - `TodoPage`: Pinned dashboard interface.
