import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aizen_theme.dart';
import '../../data/datasources/time_block_local_data_source.dart';
import '../../domain/entities/time_block.dart';

class ClaimBlockSheet extends StatefulWidget {
  final int startHour;
  final int endHour;
  final List<TimeBlock> existingBlocks;
  final String initialLabel;
  final void Function(String label, String color, int startHour, int endHour)
      onSubmit;

  const ClaimBlockSheet({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.existingBlocks,
    required this.onSubmit,
    this.initialLabel = '',
  });

  @override
  State<ClaimBlockSheet> createState() => _ClaimBlockSheetState();
}

class _ClaimBlockSheetState extends State<ClaimBlockSheet> {
  late int _startHour;
  late int _endHour;
  String _label = '';
  String _color = '7C4DFF';

  @override
  void initState() {
    super.initState();
    _startHour = widget.startHour;
    _endHour = widget.endHour;
    _label = widget.initialLabel;
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AizenTheme.surfaceLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AizenTheme.shapeLg)),
      ),
      padding: EdgeInsets.only(bottom: pad),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Claim Time Block',
              style: TextStyle(
                color: AizenTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            // Time range sliders
            _rangePicker(),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _label,
              autofocus: true,
              style: const TextStyle(
                  color: AizenTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'What will you do?',
                hintText: 'e.g. Deep Work Coding',
              ),
              onChanged: (v) => setState(() => _label = v),
            ),
            const SizedBox(height: 16),
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
                final c = _hex(hex);
                final selected = hex == _color;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _color = hex),
                  child: Container(
                    width: 32,
                    height: 32,
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
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _canSubmit() ? _submit : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Claim ${_endHour - _startHour}h '
                '(${_fmt(_startHour)} - ${_fmt(_endHour)})',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangePicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AizenTheme.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AizenTheme.hairlineBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start: ${_fmt(_startHour)}',
                style: const TextStyle(
                    color: AizenTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                'End: ${_fmt(_endHour)}',
                style: const TextStyle(
                    color: AizenTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Slider(
            value: _startHour.toDouble(),
            min: 0,
            max: 23,
            divisions: 23,
            activeColor: AizenTheme.primaryPurple,
            onChanged: (v) => setState(() {
              _startHour = v.toInt();
              if (_endHour <= _startHour) _endHour = _startHour + 1;
            }),
          ),
          Slider(
            value: _endHour.toDouble(),
            min: 1,
            max: 24,
            divisions: 23,
            activeColor: AizenTheme.primaryPurple,
            onChanged: (v) => setState(() {
              _endHour = v.toInt();
              if (_endHour <= _startHour) _startHour = _endHour - 1;
            }),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    if (_label.trim().isEmpty) return false;
    if (_endHour <= _startHour) return false;
    // Reject overlaps
    for (final b in widget.existingBlocks) {
      final overlaps =
          !(_endHour <= b.startHour || _startHour >= b.endHour);
      if (overlaps) return false;
    }
    return true;
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    widget.onSubmit(_label.trim(), _color, _startHour, _endHour);
    Navigator.of(context).pop();
  }

  String _fmt(int h) {
    if (h == 24) return '24:00';
    return '${h.toString().padLeft(2, '0')}:00';
  }

  Color _hex(String hex) {
    final v = int.tryParse(hex, radix: 16) ?? 0x7C4DFF;
    return Color(0xFF000000 | v);
  }
}
