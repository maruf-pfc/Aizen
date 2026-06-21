import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aizen_theme.dart';

class AddBillSheet extends StatefulWidget {
  final void Function(String title, double amount, int day, String category)
      onSubmit;

  const AddBillSheet({super.key, required this.onSubmit});

  @override
  State<AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends State<AddBillSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dayCtrl = TextEditingController(text: '1');
  final _categoryCtrl = TextEditingController(text: 'general');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _dayCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: pad),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Bill Reminder',
                style: TextStyle(
                  color: AizenTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _field(
                controller: _titleCtrl,
                label: 'Bill Title',
                hint: 'e.g. Internet, Rent, Electricity',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(
                      controller: _amountCtrl,
                      label: 'Amount',
                      hint: '1200',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final d = double.tryParse(v ?? '');
                        if (d == null || d <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _field(
                      controller: _dayCtrl,
                      label: 'Due Day',
                      hint: '1-31',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final d = int.tryParse(v ?? '');
                        if (d == null || d < 1 || d > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                controller: _categoryCtrl,
                label: 'Category',
                hint: 'utilities, internet, rent...',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AizenTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: validator,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    widget.onSubmit(
      _titleCtrl.text.trim(),
      double.parse(_amountCtrl.text.trim()),
      int.parse(_dayCtrl.text.trim()),
      _categoryCtrl.text.trim().isEmpty
          ? 'general'
          : _categoryCtrl.text.trim().toLowerCase(),
    );
    Navigator.of(context).pop();
  }
}
