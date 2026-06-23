# Expense & Bill Pay Module (v1.6.0)

Aizen's Expense & Bill Pay module provides a low-overhead, command-driven approach to tracking expenses alongside persistent, local notification-based recurring bill reminders.

## Key Features

1. **Command-Driven Expense Logger**:
   - A single text input parses commands such as `50 #lunch` or `-20 #refund refund on ticket`.
   - Heuristically extracts the amount (negative/positive sign support), tag (prefixed by `#`), and an optional descriptive note.
   - Low memory impact parsing without overhead.

2. **Persistent Recurring Bills**:
   - Supports defining bills with due dates, amounts, and custom categories.
   - Saves bill reminders locally to persistent storage.

3. **Daily Notification Reminders**:
   - Leverages `flutter_local_notifications` (wrapped in `BillNotificationService`) to schedule daily notifications at 09:00 AM whenever active bills are unpaid or near due.
   - Fully local setup with zero external cloud messaging or push server dependencies.

4. **High-Density Ledger UI**:
   - Tabbed view swapping between the Ledger list and the active Bills register.
   - Native Material 3 Expressive styling with clear category tags and color indicators.
   - Slide gestures (swipe-to-delete) on entries for quick transaction reversals.

## Architecture

- **`lib/features/expense_tracker/domain/services/expense_command_parser.dart`**: Parses raw console input strings into numeric amounts, hash tags, and description fields.
- **`lib/features/expense_tracker/services/bill_notification_service.dart`**: Direct interface wrapper to configure native Android notification channels and schedule periodic checks.
- **`lib/features/expense_tracker/presentation/bloc/expense_bloc.dart`**: Immutable state logic controlling loading, creating, and deleting ledger items or recurring bills.
- **`lib/features/expense_tracker/presentation/pages/expense_tracker_page.dart`**: Main viewport housing expense insertion consoles and list views.
