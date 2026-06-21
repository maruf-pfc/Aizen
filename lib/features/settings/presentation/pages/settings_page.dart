import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _importController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettingsEvent());
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0C0C0C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Import JSON Configuration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _importController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 11),
          decoration: InputDecoration(
            hintText: 'Paste backup JSON here...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              final json = _importController.text.trim();
              if (json.isNotEmpty) {
                context.read<SettingsBloc>().add(TriggerImportDataEvent(json));
              }
              Navigator.pop(dialogCtx);
              _importController.clear();
            },
            child: const Text('Import', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) => current.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message!),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF0C0C0C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
            ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings & Diagnostics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // 1. Theme Engine accordion
                _buildSectionHeader('Theme Engine'),
                const SizedBox(height: 8),
                _buildThemeOptions(context, state.settings.themeMode),
                const SizedBox(height: 24),

                // 2. Permission Diagnostics
                _buildSectionHeader('Permission Diagnostics (App Blocker v1.3.5)'),
                const SizedBox(height: 8),
                _buildPermissionRow(
                  context,
                  title: 'Usage Statistics Permission',
                  subtitle: 'Tracks foreground applications',
                  granted: state.settings.usageStatsGranted,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const TogglePermissionEvent('usageStats'));
                  },
                ),
                const Divider(color: Color(0x1AFFFFFF), height: 1),
                _buildPermissionRow(
                  context,
                  title: 'System Overlay Permission',
                  subtitle: 'Draws focus locks over system UI',
                  granted: state.settings.systemOverlayGranted,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const TogglePermissionEvent('systemOverlay'));
                  },
                ),
                const SizedBox(height: 24),

                // 3. Database Maintenance
                _buildSectionHeader('Local Database Maintenance'),
                const SizedBox(height: 8),
                _buildMaintenanceTile(
                  context,
                  icon: Icons.cleaning_services_outlined,
                  title: 'Clear Cache',
                  subtitle: 'Purge temporary key-value memory data',
                  onTap: () {
                    context.read<SettingsBloc>().add(const TriggerClearCacheEvent());
                  },
                ),
                const Divider(color: Color(0x1AFFFFFF), height: 1),
                _buildMaintenanceTile(
                  context,
                  icon: Icons.compress_outlined,
                  title: 'Optimize & Compact DB',
                  subtitle: 'Compress files and optimize memory indexing',
                  onTap: () {
                    context.read<SettingsBloc>().add(const TriggerOptimizeDbEvent());
                  },
                ),
                const Divider(color: Color(0x1AFFFFFF), height: 1),
                _buildMaintenanceTile(
                  context,
                  icon: Icons.file_upload_outlined,
                  title: 'Export JSON Backup',
                  subtitle: 'Serialize local configurations to copyable JSON',
                  onTap: () {
                    context.read<SettingsBloc>().add(const TriggerExportDataEvent());
                  },
                ),
                const Divider(color: Color(0x1AFFFFFF), height: 1),
                _buildMaintenanceTile(
                  context,
                  icon: Icons.file_download_outlined,
                  title: 'Import JSON Backup',
                  subtitle: 'Restore system settings from JSON payload',
                  onTap: () => _showImportDialog(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0x80FFFFFF),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildThemeOptions(BuildContext context, String currentTheme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ThemeChip(
              label: 'AMOLED Black',
              selected: currentTheme == 'amoled',
              onTap: () => context.read<SettingsBloc>().add(const UpdateThemeModeEvent('amoled')),
            ),
          ),
          Expanded(
            child: _ThemeChip(
              label: 'Dark Mode',
              selected: currentTheme == 'dark',
              onTap: () => context.read<SettingsBloc>().add(const UpdateThemeModeEvent('dark')),
            ),
          ),
          Expanded(
            child: _ThemeChip(
              label: 'Light Mode',
              selected: currentTheme == 'light',
              onTap: () => context.read<SettingsBloc>().add(const UpdateThemeModeEvent('light')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool granted,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: const Color(0xFF0C0C0C),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              onChanged(!granted);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Triggering native system settings overlay intent...'),
                  duration: Duration(milliseconds: 800),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: granted
                    ? const Color(0xFF00E676).withValues(alpha: 0.1)
                    : const Color(0xFFFF5252).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: granted
                      ? const Color(0xFF00E676).withValues(alpha: 0.3)
                      : const Color(0xFFFF5252).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                granted ? 'GRANTED' : 'MISSING',
                style: TextStyle(
                  color: granted ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF0C0C0C),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 14,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C4DFF).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF7C4DFF) : Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: selected ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
