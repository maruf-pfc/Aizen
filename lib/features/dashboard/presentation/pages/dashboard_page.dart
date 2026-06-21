import 'package:flutter/material.dart';
import '../../../device_info/presentation/pages/device_info_page.dart';
import '../../../stopwatch/presentation/pages/stopwatch_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: _currentIndex == 0 ? const StopwatchPage() : const DeviceInfoPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF000000),
          selectedItemColor: const Color(0xFF7C4DFF),
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
          currentIndex: _currentIndex,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined, size: 20),
              activeIcon: Icon(Icons.timer, size: 20),
              label: 'Stopwatch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline, size: 20),
              activeIcon: Icon(Icons.info, size: 20),
              label: 'Specs',
            ),
          ],
        ),
      ),
    );
  }
}
