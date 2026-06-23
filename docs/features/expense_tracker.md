# Expense & Bill Pay Module (v1.5.0)

Aizen's Expense & Bill Pay module provides a low-overhead, command-driven approach to tracking expenses alongside persistent, local notification-based recurring bill reminders and Koinly-inspired category analytics.

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

4. **Koinly-Inspired Analytics & Category Breakdown**:
   - A dedicated **Analytics** tab summarizing total refunds/income, total expenses, net balance, and daily spending averages.
   - Beautiful **Category Spending Breakdown** lists categorizing spending by hashtags with percentage contributions and linear progress tracking.

5. **High-Density Ledger & Sleek UI**:
   - Tabbed view swapping between Ledger, Analytics, and active Bills.
   - Integrated Koinly Sleek Dark Palette with vibrant `#00C7D8` Cyan accent, `#061012` deep background, and `#10191D` custom cards.
   - Slide gestures (swipe-to-delete) on entries for quick transaction reversals.

## Architecture

- **`lib/features/expense_tracker/domain/services/expense_command_parser.dart`**: Parses raw console input strings into numeric amounts, hash tags, and description fields.
- **`lib/features/expense_tracker/services/bill_notification_service.dart`**: Direct interface wrapper to configure native Android notification channels and schedule periodic checks.
- **`lib/features/expense_tracker/presentation/bloc/expense_bloc.dart`**: Immutable state logic controlling loading, creating, and deleting ledger items or recurring bills.
- **`lib/features/expense_tracker/presentation/pages/expense_tracker_page.dart`**: Main viewport housing expense insertion consoles, analytics breakdown, and list views.
