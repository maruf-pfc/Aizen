# Time Blocker / Day Planner Module (v1.5.0)

The Time Blocker (or Day Planner) is a high-density, interactive 24-hour visual grid planner. It allows users to partition their day into distinct hourly blocks, track active block progress in real-time, and mark blocks complete.

## Key Features

1. **24-Hour Visual Grid**:
   - Renders a continuous, interactive vertical track mapping every hour of the selected calendar day.
   - Distinct visual states distinguish between unclaimed hours (dashed borders) and claimed blocks.

2. **Real-time Block Progress Indicator**:
   - An active block shows a real-time progress bar reflecting the exact elapsed time within that hourly window.
   - Smooth layout updates without triggering parent screen rebuilds.

3. **Time Block Properties**:
   - Custom labels for each hour.
   - Color code blocks using a Material 3 palette.
   - Fast checkmark updates to mark blocks as "Done".

4. **Date Navigation**:
   - Horizontal sliding day selector to view, configure, and manage schedules across different dates.
   - Lazy-loads calendar days to maintain local RAM limits.

## Architecture

- **`lib/features/time_blocker/data/datasources/time_block_local_data_source.dart`**: Stores daily schedules in a JSON map format inside local storage.
- **`lib/features/time_blocker/presentation/bloc/time_block_bloc.dart`**: Oversees layout changes, block state updates, and calendar day paging.
- **`lib/features/time_blocker/presentation/pages/time_blocker_page.dart`**: Employs responsive vertical scroll columns, color picker sheets, and elapsed time tickers.
