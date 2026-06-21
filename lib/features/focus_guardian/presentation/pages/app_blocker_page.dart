import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/focus_bridge_service.dart';

class AppBlockerPage extends StatefulWidget {
  const AppBlockerPage({super.key});

  @override
  State<AppBlockerPage> createState() => _AppBlockerPageState();
}

class _AppBlockerPageState extends State<AppBlockerPage> {
  final FocusBridgeService _bridgeService = FocusBridgeService();
  List<Map<String, String>> _installedApps = [];
  Set<String> _blockedPackages = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBlockedAppsAndRefresh();
  }

  Future<void> _loadBlockedAppsAndRefresh() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedBlocked = prefs.getStringList('blocked_packages') ?? [];
    
    // Fetch apps from native Android side
    final apps = await _bridgeService.getInstalledApps();
    
    setState(() {
      _blockedPackages = savedBlocked.toSet();
      _installedApps = apps;
      _isLoading = false;
    });

    // Make sure native service is updated with current saved list on load
    await _bridgeService.updateBlacklistData(savedBlocked);
  }

  Future<void> _toggleAppBlock(String packageName) async {
    setState(() {
      if (_blockedPackages.contains(packageName)) {
        _blockedPackages.remove(packageName);
      } else {
        _blockedPackages.add(packageName);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String> list = _blockedPackages.toList();
    await prefs.setStringList('blocked_packages', list);
    
    // Synchronize to native side
    await _bridgeService.updateBlacklistData(list);
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _installedApps.where((app) {
      final name = app['name']?.toLowerCase() ?? '';
      final pkg = app['packageName']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || pkg.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Focus Guardian (App Blocker)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: _loadBlockedAppsAndRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search installed apps...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Header info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredApps.length} APPS INSTALLED',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${_blockedPackages.length} BLOCKED',
                  style: const TextStyle(
                    color: Color(0xFF7C4DFF),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x13FFFFFF)),

          // Apps List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C4DFF),
                      strokeWidth: 2,
                    ),
                  )
                : filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          'No apps found',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredApps.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: Color(0x0AFFFFFF),
                        ),
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          final name = app['name'] ?? 'Unknown';
                          final pkg = app['packageName'] ?? '';
                          final isBlocked = _blockedPackages.contains(pkg);

                          return SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            activeThumbColor: const Color(0xFF7C4DFF),
                            activeTrackColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                            inactiveThumbColor: Colors.white60,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                            title: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              pkg,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                            value: isBlocked,
                            onChanged: (val) => _toggleAppBlock(pkg),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
