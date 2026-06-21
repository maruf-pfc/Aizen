import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../../domain/entities/navigation_item.dart';
import '../../domain/entities/module_category.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../focus_guardian/presentation/pages/app_blocker_page.dart';

abstract class VisualNode {}

class HeaderNode extends VisualNode {
  final ModuleCategory category;
  HeaderNode(this.category);
}

class ItemNode extends VisualNode {
  final NavigationItem item;
  ItemNode(this.item);
}

class NavigationHubDrawer extends StatefulWidget {
  const NavigationHubDrawer({super.key});

  @override
  State<NavigationHubDrawer> createState() => _NavigationHubDrawerState();
}

class _NavigationHubDrawerState extends State<NavigationHubDrawer> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NavigationBloc>().add(const LoadNavigationEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VisualNode> _flattenCategories(List<ModuleCategory> categories) {
    final List<VisualNode> nodes = [];
    for (final category in categories) {
      nodes.add(HeaderNode(category));
      if (!category.isCollapsed) {
        for (final item in category.items) {
          nodes.add(ItemNode(item));
        }
      }
    }
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF000000),
      child: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0C0C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search active modules...',
                          hintStyle: TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        onChanged: (val) {
                          context.read<NavigationBloc>().add(SearchQueryChangedEvent(val));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Flattened list using ListView.builder for RAM optimization
            Expanded(
              child: BlocBuilder<NavigationBloc, NavigationState>(
                builder: (context, state) {
                  final nodes = _flattenCategories(state.filteredCategories);

                  if (state.status == NavigationStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C4DFF),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (nodes.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching modules found',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 11,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: nodes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      if (node is HeaderNode) {
        final cat = node.category;
        return InkWell(
          onTap: () {
            context.read<NavigationBloc>().add(ToggleCategoryCollapseEvent(cat.id));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  cat.isCollapsed ? Icons.chevron_right : Icons.expand_more,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${cat.items.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (node is ItemNode) {
        final item = node.item;
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            if (item.id == 'stopwatch') {
              context.read<NavigationBloc>().add(const ChangeActiveIndexEvent(0));
            } else if (item.id == 'quick_tasks') {
              context.read<NavigationBloc>().add(const ChangeActiveIndexEvent(1));
            } else if (item.id == 'device_specs') {
              context.read<NavigationBloc>().add(const ChangeActiveIndexEvent(2));
            } else if (item.id == 'app_blocker') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppBlockerPage(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    },
  );
},
              ),
            ),
            // Bottom Settings Sticky Row
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // Close Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Settings & Diagnostics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
