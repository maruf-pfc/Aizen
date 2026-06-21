import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../device_info/presentation/pages/device_info_page.dart';
import '../../../stopwatch/presentation/pages/stopwatch_page.dart';
import '../../../todo/presentation/pages/todo_page.dart';
import '../../../calculator/presentation/pages/calculator_page.dart';
import '../../../navigation_hub/presentation/widgets/navigation_hub_drawer.dart';
import '../../../navigation_hub/presentation/bloc/navigation_bloc.dart';
import '../../../navigation_hub/presentation/bloc/navigation_event.dart';
import '../../../navigation_hub/presentation/bloc/navigation_state.dart';
import 'package:Aizen/core/theme/aizen_theme.dart';

/// Aizen v1.4.2 — Dashboard with M3 NavigationBar.
///
/// The bottom navigation bar exposes the 4 most-used modules (Stopwatch,
/// Tasks, Calculator, Specs) with native M3 indicators and pill highlights.
/// The full module inventory lives in the drawer (hamburger menu).
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _pages = <Widget>[
    StopwatchPage(),
    TodoPage(),
    CalculatorPage(),
    DeviceInfoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final index = state.activeIndex.clamp(0, _pages.length - 1);
        return Scaffold(
          backgroundColor: AizenTheme.amoledBlack,
          drawer: const NavigationHubDrawer(),
          body: IndexedStack(index: index, children: _pages),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AizenTheme.hairlineBorder, width: 1),
              ),
            ),
            child: NavigationBar(
              backgroundColor: AizenTheme.amoledBlack,
              surfaceTintColor: Colors.transparent,
              selectedIndex: index,
              onDestinationSelected: (i) {
                context
                    .read<NavigationBloc>()
                    .add(ChangeActiveIndexEvent(i));
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  selectedIcon: Icon(Icons.timer),
                  label: 'Stopwatch',
                ),
                NavigationDestination(
                  icon: Icon(Icons.playlist_add_check_outlined),
                  selectedIcon: Icon(Icons.task_alt),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate),
                  label: 'Calc',
                ),
                NavigationDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: 'Specs',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
