import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../device_info/presentation/pages/device_info_page.dart';
import '../../../stopwatch/presentation/pages/stopwatch_page.dart';
import '../../../todo/presentation/pages/todo_page.dart';
import '../../../navigation_hub/presentation/widgets/navigation_hub_drawer.dart';
import '../../../navigation_hub/presentation/bloc/navigation_bloc.dart';
import '../../../navigation_hub/presentation/bloc/navigation_event.dart';
import '../../../navigation_hub/presentation/bloc/navigation_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF000000),
          drawer: const NavigationHubDrawer(),
          body: state.activeIndex == 0
              ? const StopwatchPage()
              : state.activeIndex == 1
                  ? const TodoPage()
                  : const DeviceInfoPage(),
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
              currentIndex: state.activeIndex,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                context.read<NavigationBloc>().add(ChangeActiveIndexEvent(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer_outlined, size: 20),
                  activeIcon: Icon(Icons.timer, size: 20),
                  label: 'Stopwatch',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.playlist_add_check, size: 20),
                  activeIcon: Icon(Icons.task_alt, size: 20),
                  label: 'Tasks',
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
      },
    );
  }
}
