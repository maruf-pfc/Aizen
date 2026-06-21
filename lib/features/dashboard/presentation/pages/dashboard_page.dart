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

/// Aizen v1.4.2 — Dashboard with M3 Expressive NavigationBar.
///
/// Responsive layout: the NavigationBar indicator uses a full pill shape.
/// Tab body transitions use an AnimatedSwitcher with spring-deceleration
/// for a fluid, native-feeling page swap.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _prevIndex = 0;

  static const _pages = <Widget>[
    StopwatchPage(),
    TodoPage(),
    CalculatorPage(),
    DeviceInfoPage(),
  ];

  static const _navItems = [
    (icon: Icons.timer_outlined, selectedIcon: Icons.timer, label: 'Stopwatch'),
    (icon: Icons.playlist_add_check_outlined, selectedIcon: Icons.task_alt, label: 'Tasks'),
    (icon: Icons.calculate_outlined, selectedIcon: Icons.calculate, label: 'Calc'),
    (icon: Icons.info_outline, selectedIcon: Icons.info, label: 'Specs'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationBloc, NavigationState>(
      listenWhen: (p, c) => p.activeIndex != c.activeIndex,
      listener: (context, state) {
        setState(() => _prevIndex = state.activeIndex);
      },
      builder: (context, state) {
        final index = state.activeIndex.clamp(0, _pages.length - 1);
        final goingForward = index >= _prevIndex;

        return Scaffold(
          backgroundColor: AizenTheme.amoledBlack,
          drawer: const NavigationHubDrawer(),
          // Animated tab body with spring deceleration slide
          body: AnimatedSwitcher(
            duration: AizenTheme.motionMedium,
            switchInCurve: AizenTheme.springCurve,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetBegin = Offset(goingForward ? 0.03 : -0.03, 0);
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.8),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: offsetBegin,
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: AizenTheme.springCurve,
                  )),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(index),
              child: _pages[index],
            ),
          ),
          bottomNavigationBar: _AizenNavBar(
            index: index,
            items: _navItems,
            onSelect: (i) {
              if (i == index) return;
              setState(() => _prevIndex = index);
              context.read<NavigationBloc>().add(ChangeActiveIndexEvent(i));
            },
          ),
        );
      },
    );
  }
}

// ── M3 Expressive Navigation Bar ─────────────────────────────────────────────
class _AizenNavBar extends StatelessWidget {
  final int index;
  final List<({IconData icon, IconData selectedIcon, String label})> items;
  final ValueChanged<int> onSelect;

  const _AizenNavBar({
    required this.index,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AizenTheme.amoledBlack,
        border: Border(
          top: BorderSide(color: AizenTheme.hairlineBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomPadding > 0 ? 0 : 4,
            top: 4,
          ),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavBarItem(
                    icon: items[i].icon,
                    selectedIcon: items[i].selectedIcon,
                    label: items[i].label,
                    isSelected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _indicatorWidth;
  late final Animation<double> _iconSize;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AizenTheme.motionMedium,
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _indicatorWidth = Tween<double>(begin: 0, end: 56).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _iconSize = Tween<double>(begin: 22, end: 24).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AizenTheme.primaryPurple
        : AizenTheme.textTertiary;

    return GestureDetector(
      onTap: () {
        AizenHaptics.selection();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              // Pill indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: AizenTheme.motionMedium,
                    curve: Curves.easeOutCubic,
                    width: _indicatorWidth.value,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AizenTheme.primaryPurple.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AizenTheme.shapeFull),
                    ),
                  ),
                  ScaleTransition(
                    scale: _scale,
                    child: Icon(
                      widget.isSelected ? widget.selectedIcon : widget.icon,
                      color: color,
                      size: _iconSize.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AizenTheme.motionShort,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 4),
            ],
          );
        },
      ),
    );
  }
}
