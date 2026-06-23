import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../data/datasources/time_block_local_data_source.dart';
import '../../domain/entities/time_block.dart';
import '../bloc/time_block_bloc.dart';
import '../bloc/time_block_event.dart';
import '../bloc/time_block_state.dart';
import '../widgets/claim_block_sheet.dart';
import '../../../todo/presentation/bloc/todo_bloc.dart';
import '../../../todo/presentation/bloc/todo_state.dart';
import '../../../todo/domain/entities/task.dart';

class TimeBlockerPage extends StatefulWidget {
  const TimeBlockerPage({super.key});

  @override
  State<TimeBlockerPage> createState() => _TimeBlockerPageState();
}

class _TimeBlockerPageState extends State<TimeBlockerPage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context
        .read<TimeBlockBloc>()
        .add(LoadDayEvent(DateTime(now.year, now.month, now.day)));
    // Re-render every 30s to keep the micro-progress indicators fresh.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AizenTheme.amoledBlack,
      appBar: AppBar(
        backgroundColor: AizenTheme.amoledBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Day Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, size: 20),
            tooltip: 'Jump to today',
            onPressed: () {
              final now = DateTime.now();
              context
                  .read<TimeBlockBloc>()
                  .add(ChangeSelectedDayEvent(DateTime(now.year, now.month, now.day)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            tooltip: 'Clear day',
            onPressed: () {
              AizenHaptics.medium();
              context.read<TimeBlockBloc>().add(const ClearDayEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<TimeBlockBloc, TimeBlockState>(
        builder: (ctx, state) {
          return BlocBuilder<TodoBloc, TodoState>(
            builder: (ctx, todoState) {
              return Column(
                children: [
                  _buildHeader(state),
                  Expanded(child: _buildMatrix(ctx, state, todoState)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(TimeBlockState state) {
    final now = DateTime.now();
    final isToday = state.selectedDay.year == now.year &&
        state.selectedDay.month == now.month &&
        state.selectedDay.day == now.day;

    final active = state.activeNow;
    final claimedPct =
        ((state.claimedHours / 24) * 100).clamp(0, 100).toDouble();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AizenTheme.surfaceMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AizenTheme.hairlineBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _changeDay(state.selectedDay, -1),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.chevron_left,
                      color: AizenTheme.textSecondary, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(state.selectedDay),
                  child: Column(
                    children: [
                      Text(
                        _dayTitle(state.selectedDay, isToday),
                        style: const TextStyle(
                          color: AizenTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _dateLabel(state.selectedDay),
                        style: const TextStyle(
                          color: AizenTheme.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _changeDay(state.selectedDay, 1),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.chevron_right,
                      color: AizenTheme.textSecondary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: claimedPct / 100,
                    minHeight: 6,
                    backgroundColor: AizenTheme.surfaceHigh,
                    color: AizenTheme.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.claimedHours}h / 24h',
                style: const TextStyle(
                  color: AizenTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (active != null && isToday) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _hexColor(active.color).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hexColor(active.color).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 14, color: _hexColor(active.color)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'NOW: ${active.label} '
                      '(${_fmtHour(active.startHour)}-${_fmtHour(active.endHour)})',
                      style: TextStyle(
                        color: _hexColor(active.color),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatrix(BuildContext ctx, TimeBlockState state, TodoState todoState) {
    final now = DateTime.now();
    final isToday = state.selectedDay.year == now.year &&
        state.selectedDay.month == now.month &&
        state.selectedDay.day == now.day;
    final currentHour = now.hour;

    // Filter uncompleted !!1 tasks
    final highPriorityTasks = todoState.tasks
        .where((t) => !t.isCompleted && t.priority == 1)
        .toList();

    // Map empty slots to tasks
    final emptyHours = List.generate(24, (i) => i)
        .where((h) => state.blockAt(h) == null)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      itemCount: 24,
      itemExtent: 56,
      itemBuilder: (ctx, hour) {
        final block = state.blockAt(hour);
        final isNowRow = isToday && hour == currentHour;
        // Skip rows that are mid-block (rendered by the block's start row).
        if (block != null && hour != block.startHour) {
          return const SizedBox.shrink();
        }
        if (block != null) {
          return _buildBlockRow(
            block: block,
            isNowRow: isNowRow,
            isToday: isToday,
            now: now,
            state: state,
          );
        }

        // Find if this hour has a suggestion
        final emptyIndex = emptyHours.indexOf(hour);
        Task? suggestedTask;
        if (emptyIndex != -1 && emptyIndex < highPriorityTasks.length) {
          suggestedTask = highPriorityTasks[emptyIndex];
        }

        return _buildEmptyHourRow(
          hour: hour,
          isNowRow: isNowRow,
          suggestedTaskTitle: suggestedTask?.title,
          onTap: () => _showClaimSheet(
            ctx,
            hour,
            hour + 1,
            state,
            suggestedTask?.title ?? '',
          ),
        );
      },
    );
  }

  Widget _buildEmptyHourRow({
    required int hour,
    required bool isNowRow,
    required VoidCallback onTap,
    String? suggestedTaskTitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AizenHaptics.selection();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isNowRow
                ? AizenTheme.primaryPurple.withValues(alpha: 0.06)
                : AizenTheme.surfaceLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isNowRow
                  ? AizenTheme.primaryPurple.withValues(alpha: 0.4)
                  : AizenTheme.hairlineBorder,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  _fmtHour(hour),
                  style: TextStyle(
                    color: isNowRow
                        ? AizenTheme.primaryPurple
                        : AizenTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: suggestedTaskTitle != null
                    ? Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: AizenTheme.accentAmber, size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Suggest: $suggestedTaskTitle',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AizenTheme.accentAmber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        isNowRow ? 'Tap to claim this hour' : '—',
                        style: TextStyle(
                          color: isNowRow
                              ? AizenTheme.textSecondary
                              : AizenTheme.textTertiary,
                          fontSize: 11,
                          fontStyle: isNowRow ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
              ),
              Icon(Icons.add_circle_outline,
                  size: 14, color: suggestedTaskTitle != null ? AizenTheme.accentAmber : AizenTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockRow({
    required TimeBlock block,
    required bool isNowRow,
    required bool isToday,
    required DateTime now,
    required TimeBlockState state,
  }) {
    final color = _hexColor(block.color);
    final height = 56.0 * block.durationHours - 4;
    final elapsed = isToday ? block.elapsedFraction(now) : (block.completed ? 1.0 : 0.0);

    return GestureDetector(
      onLongPress: () => _showBlockActions(block),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Stack(
          children: [
            // Elapsed progress fill (left edge)
            if (isToday && !block.completed && elapsed > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: LinearProgressIndicator(
                    value: elapsed,
                    minHeight: height,
                    backgroundColor: color.withValues(alpha: 0.18),
                    color: color,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _fmtHour(block.startHour),
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_fmtHour(block.startHour)} - ${_fmtHour(block.endHour)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (block.completed)
                        Icon(Icons.check_circle,
                            color: color, size: 14)
                      else if (isToday && block.isNow(now))
                        Icon(Icons.play_circle_fill,
                            color: color, size: 14),
                      // Overflow menu
                      InkWell(
                        onTap: () => _showBlockActions(block),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.more_vert,
                              color: color, size: 14),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    block.label,
                    maxLines: block.durationHours > 1 ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AizenTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (block.durationHours > 1 || isToday) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: block.completed ? 1.0 : elapsed,
                        minHeight: 3,
                        backgroundColor: color.withValues(alpha: 0.18),
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  String _dayTitle(DateTime d, bool isToday) {
    if (isToday) { return 'TODAY'; }
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day) { return 'TOMORROW'; }
    return _weekday(d.weekday).toUpperCase();
  }

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';

  String _weekday(int w) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[w - 1];
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  String _fmtHour(int h) {
    if (h == 24) return '24:00';
    return '${h.toString().padLeft(2, '0')}:00';
  }

  Color _hexColor(String hex) {
    final v = int.tryParse(hex.replaceAll('#', ''), radix: 16) ?? 0x7C4DFF;
    return Color(0xFF000000 | v);
  }

  void _changeDay(DateTime current, int delta) {
    AizenHaptics.selection();
    final next = DateTime(current.year, current.month, current.day + delta);
    context.read<TimeBlockBloc>().add(ChangeSelectedDayEvent(next));
  }

  Future<void> _pickDate(DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AizenTheme.primaryPurple,
                onPrimary: Colors.black,
                surface: AizenTheme.surfaceMid,
                onSurface: AizenTheme.textPrimary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      context.read<TimeBlockBloc>().add(ChangeSelectedDayEvent(picked));
    }
  }

  void _showClaimSheet(
      BuildContext ctx, int startHour, int endHour, TimeBlockState state,
      [String initialLabel = '']) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ClaimBlockSheet(
        startHour: startHour,
        endHour: endHour,
        existingBlocks: state.blocks,
        initialLabel: initialLabel,
        onSubmit: (label, color, sH, eH) {
          context.read<TimeBlockBloc>().add(ClaimHoursEvent(
                startHour: sH,
                endHour: eH,
                label: label,
                color: color,
              ));
        },
      ),
    );
  }

  void _showBlockActions(TimeBlock block) {
    AizenHaptics.light();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(block.completed
                  ? Icons.undo_outlined
                  : Icons.check_circle_outline),
              title: Text(block.completed ? 'Mark as not done' : 'Mark complete'),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<TimeBlockBloc>()
                    .add(ToggleBlockCompletedEvent(block.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit label'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditLabelSheet(block);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AizenTheme.accentRed),
              title: const Text('Delete block',
                  style: TextStyle(color: AizenTheme.accentRed)),
              onTap: () {
                Navigator.pop(ctx);
                context.read<TimeBlockBloc>().add(DeleteBlockEvent(block.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLabelSheet(TimeBlock block) {
    final ctrl = TextEditingController(text: block.label);
    String selectedColor = block.color;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            final pad = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: pad),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Edit Block',
                      style: TextStyle(
                        color: AizenTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ctrl,
                      autofocus: true,
                      style: const TextStyle(
                          color: AizenTheme.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Label',
                        hintText: 'e.g. Deep Work Coding',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'COLOR',
                      style: TextStyle(
                        color: AizenTheme.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: TimeBlockPalette.all.map((hex) {
                        final c = _hexColor(hex);
                        final selected = hex == selectedColor;
                        return GestureDetector(
                          onTap: () => setS(() => selectedColor = hex),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? AizenTheme.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        final label = ctrl.text.trim();
                        if (label.isEmpty) return;
                        HapticFeedback.mediumImpact();
                        context.read<TimeBlockBloc>().add(UpdateBlockEvent(
                              id: block.id,
                              label: label,
                              color: selectedColor,
                            ));
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
