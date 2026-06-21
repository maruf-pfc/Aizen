import 'package:flutter/material.dart' hide ClipboardStatus;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../domain/entities/clipboard_item.dart';
import '../bloc/clipboard_bloc.dart';
import '../bloc/clipboard_event.dart';
import '../bloc/clipboard_state.dart';
import '../widgets/clipboard_item_row.dart';

class ClipboardVaultPage extends StatefulWidget {
  const ClipboardVaultPage({super.key});

  @override
  State<ClipboardVaultPage> createState() => _ClipboardVaultPageState();
}

class _ClipboardVaultPageState extends State<ClipboardVaultPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClipboardBloc>().add(const LoadClipboardEvent());
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
        title: const Text('Clipboard Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste_go, size: 20),
            tooltip: 'Capture from clipboard',
            onPressed: () {
              AizenHaptics.light();
              context.read<ClipboardBloc>().captureFromSystemClipboard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            tooltip: 'Clear all (pinned preserved)',
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: BlocBuilder<ClipboardBloc, ClipboardState>(
        builder: (ctx, state) {
          return Column(
            children: [
              _buildStatsBar(state),
              _buildFilterChips(state),
              Expanded(child: _buildList(ctx, state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AizenHaptics.light();
          context.read<ClipboardBloc>().captureFromSystemClipboard();
        },
        backgroundColor: AizenTheme.primaryPurple,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Capture'),
      ),
    );
  }

  Widget _buildStatsBar(ClipboardState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AizenTheme.surfaceMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AizenTheme.hairlineBorder),
      ),
      child: Row(
        children: [
          _stat('Total', state.items.length.toString(), AizenTheme.textPrimary),
          _divider(),
          _stat('Links', state.totalLinks.toString(), AizenTheme.accentCyan),
          _divider(),
          _stat('Snippets', state.totalSnippets.toString(),
              AizenTheme.accentAmber),
          _divider(),
          _stat('Plain', state.totalPlain.toString(), AizenTheme.accentGreen),
          const Spacer(),
          Text(
            'CAP 50',
            style: TextStyle(
              color: state.items.length >= 45
                  ? AizenTheme.accentRed
                  : AizenTheme.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AizenTheme.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 1,
      height: 22,
      color: AizenTheme.hairlineBorder,
    );
  }

  Widget _buildFilterChips(ClipboardState state) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _filterChip('All', state.items.length, ClipboardFilter.all,
              state.filter == ClipboardFilter.all),
          _filterChip('Links', state.totalLinks, ClipboardFilter.link,
              state.filter == ClipboardFilter.link),
          _filterChip('Snippets', state.totalSnippets, ClipboardFilter.snippet,
              state.filter == ClipboardFilter.snippet),
          _filterChip('Plain', state.totalPlain, ClipboardFilter.plain,
              state.filter == ClipboardFilter.plain),
        ],
      ),
    );
  }

  Widget _filterChip(
      String label, int count, ClipboardFilter f, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: selected,
        onSelected: (_) {
          AizenHaptics.selection();
          context.read<ClipboardBloc>().add(ChangeClipboardFilterEvent(f));
        },
        selectedColor: AizenTheme.primaryPurple.withValues(alpha: 0.22),
        checkmarkColor: AizenTheme.primaryPurple,
        backgroundColor: AizenTheme.surfaceHigh,
        labelStyle: TextStyle(
          color: selected ? AizenTheme.primaryPurple : AizenTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AizenTheme.hairlineBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }

  Widget _buildList(BuildContext ctx, ClipboardState state) {
    if (state.status == ClipboardStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AizenTheme.primaryPurple,
          strokeWidth: 2,
        ),
      );
    }
    final items = state.filtered;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.content_paste_off_outlined,
                  color: AizenTheme.textTertiary, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Vault is empty',
                style: TextStyle(
                  color: AizenTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap "Capture" to pull the latest text from your system clipboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AizenTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AizenTheme.hairlineBorder),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return ClipboardItemRow(
          item: item,
          onTap: () async {
            AizenHaptics.light();
            await Clipboard.setData(ClipboardData(text: item.content));
            if (!ctx.mounted) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text('Copied back to clipboard'),
                duration: Duration(milliseconds: 1200),
              ),
            );
          },
          onTogglePin: () {
            AizenHaptics.selection();
            context
                .read<ClipboardBloc>()
                .add(TogglePinClipboardItemEvent(item.id));
          },
          onDelete: () {
            AizenHaptics.light();
            context.read<ClipboardBloc>().add(DeleteClipboardItemEvent(item.id));
          },
        );
      },
    );
  }

  void _confirmClear() {
    AizenHaptics.medium();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Clear Clipboard Vault?',
                style: TextStyle(
                  color: AizenTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pinned items will be preserved. This action cannot be undone.',
                style: TextStyle(
                  color: AizenTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AizenTheme.accentRed,
                      ),
                      onPressed: () {
                        context
                            .read<ClipboardBloc>()
                            .add(const ClearAllClipboardEvent());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
