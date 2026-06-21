import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/navigation_item.dart';
import '../../domain/entities/module_category.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<LoadNavigationEvent>(_onLoadNavigation);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<ToggleCategoryCollapseEvent>(_onToggleCategoryCollapse);
  }

  void _onLoadNavigation(
    LoadNavigationEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(status: NavigationStatus.loading));

    final categories = [
      ModuleCategory(
        id: 'focus',
        name: 'Focus & Flow',
        items: [
          const NavigationItem(id: 'app_blocker', title: 'App Blocker v1.3.5', icon: Icons.block, category: 'focus', badge: 'Active'),
          const NavigationItem(id: 'pomodoro', title: 'Pomodoro Clock', icon: Icons.timer, category: 'focus'),
          const NavigationItem(id: 'screen_limit', title: 'Screen Limiter', icon: Icons.screen_lock_portrait, category: 'focus'),
          const NavigationItem(id: 'focus_room', title: 'Focus Room', icon: Icons.meeting_room, category: 'focus'),
          const NavigationItem(id: 'white_noise', title: 'White Noise Generator', icon: Icons.graphic_eq, category: 'focus'),
          const NavigationItem(id: 'zen_write', title: 'Zen Write', icon: Icons.edit, category: 'focus'),
          const NavigationItem(id: 'deep_work', title: 'Deep Work Analytics', icon: Icons.analytics, category: 'focus', badge: 'New'),
          const NavigationItem(id: 'site_block', title: 'Site Blocker', icon: Icons.web_asset_off, category: 'focus'),
          const NavigationItem(id: 'notif_filter', title: 'Notification Filter', icon: Icons.notifications_off, category: 'focus'),
          const NavigationItem(id: 'mindful_breaths', title: 'Mindful Breaths', icon: Icons.air, category: 'focus'),
          const NavigationItem(id: 'dnd_scheduler', title: 'DND Scheduler', icon: Icons.do_not_disturb_on, category: 'focus'),
          const NavigationItem(id: 'digital_detox', title: 'Digital Detox', icon: Icons.phonelink_erase, category: 'focus'),
          const NavigationItem(id: 'focus_group', title: 'Focus Group', icon: Icons.group_work, category: 'focus'),
          const NavigationItem(id: 'task_batching', title: 'Task Batching', icon: Icons.dynamic_feed, category: 'focus'),
          const NavigationItem(id: 'flow_ticker', title: 'Flow Ticker', icon: Icons.speed, category: 'focus'),
        ],
      ),
      ModuleCategory(
        id: 'tasks',
        name: 'Task Management',
        items: [
          const NavigationItem(id: 'quick_tasks', title: 'Quick Tasks', icon: Icons.playlist_add_check, category: 'tasks'),
          const NavigationItem(id: 'things_sync', title: 'Things 3 Sync', icon: Icons.sync, category: 'tasks'),
          const NavigationItem(id: 'kanban', title: 'Kanban Board', icon: Icons.dashboard, category: 'tasks'),
          const NavigationItem(id: 'calendar_agg', title: 'Calendar Aggregator', icon: Icons.calendar_month, category: 'tasks'),
          const NavigationItem(id: 'recurring_rules', title: 'Recurring Rules', icon: Icons.autorenew, category: 'tasks'),
          const NavigationItem(id: 'subtask_tree', title: 'Subtask Tree', icon: Icons.account_tree_outlined, category: 'tasks'),
          const NavigationItem(id: 'tags_index', title: 'Tags Index', icon: Icons.tag, category: 'tasks'),
          const NavigationItem(id: 'inbox', title: 'Inbox', icon: Icons.inbox, category: 'tasks'),
          const NavigationItem(id: 'archive_vault', title: 'Archive Vault', icon: Icons.archive, category: 'tasks'),
          const NavigationItem(id: 'radar', title: 'High-Priority Radar', icon: Icons.radar, category: 'tasks', badge: 'Alert'),
          const NavigationItem(id: 'timeboxer', title: 'Timeboxer', icon: Icons.view_timeline, category: 'tasks'),
          const NavigationItem(id: 'eisenhower', title: 'Eisenhower Matrix', icon: Icons.grid_view, category: 'tasks'),
          const NavigationItem(id: 'project_logs', title: 'Project Logs', icon: Icons.book, category: 'tasks'),
          const NavigationItem(id: 'habit_tracker', title: 'Habit Tracker', icon: Icons.repeat, category: 'tasks'),
          const NavigationItem(id: 'review_weekly', title: 'Review Weekly', icon: Icons.rate_review, category: 'tasks'),
        ],
      ),
      ModuleCategory(
        id: 'utils',
        name: 'System Utilities',
        items: [
          const NavigationItem(id: 'device_specs', title: 'Device Specs', icon: Icons.info_outline, category: 'utils'),
          const NavigationItem(id: 'battery_monitor', title: 'Battery Monitor', icon: Icons.battery_charging_full, category: 'utils'),
          const NavigationItem(id: 'storage_segmenter', title: 'Storage Segmenter', icon: Icons.storage, category: 'utils'),
          const NavigationItem(id: 'ram_cleaner', title: 'Ram Cleaner', icon: Icons.cleaning_services, category: 'utils'),
          const NavigationItem(id: 'cache_compactor', title: 'Cache Compactor', icon: Icons.compress, category: 'utils'),
          const NavigationItem(id: 'cpu_monitor', title: 'CPU Monitor', icon: Icons.memory, category: 'utils'),
          const NavigationItem(id: 'permissions', title: 'Permission Diagnostics', icon: Icons.verified_user, category: 'utils'),
          const NavigationItem(id: 'db_maintenance', title: 'Local DB Maintenance', icon: Icons.dns, category: 'utils'),
          const NavigationItem(id: 'overlay_manager', title: 'System Overlay Manager', icon: Icons.layers, category: 'utils'),
          const NavigationItem(id: 'import_export', title: 'Import-Export Engine', icon: Icons.import_export, category: 'utils'),
          const NavigationItem(id: 'logs_auditor', title: 'Logs Auditor', icon: Icons.assignment, category: 'utils'),
          const NavigationItem(id: 'theme_switcher', title: 'Theme Switcher', icon: Icons.palette, category: 'utils'),
          const NavigationItem(id: 'network_diag', title: 'Network Diagnostics', icon: Icons.network_check, category: 'utils'),
          const NavigationItem(id: 'disk_analyser', title: 'Disk Analyser', icon: Icons.donut_large, category: 'utils'),
          const NavigationItem(id: 'kernel_specs', title: 'Kernel Specifier', icon: Icons.settings_applications, category: 'utils'),
        ],
      ),
      ModuleCategory(
        id: 'personal',
        name: 'Personal Development',
        items: [
          const NavigationItem(id: 'goals', title: 'Goal Tracker', icon: Icons.track_changes, category: 'personal'),
          const NavigationItem(id: 'journal', title: 'Journal Daily', icon: Icons.note_alt, category: 'personal'),
          const NavigationItem(id: 'book_track', title: 'Book Tracker', icon: Icons.menu_book, category: 'personal'),
          const NavigationItem(id: 'quote_widget', title: 'Quote Widgets', icon: Icons.format_quote, category: 'personal'),
          const NavigationItem(id: 'skill_tree', title: 'Skill Tree', icon: Icons.nature_people, category: 'personal'),
          const NavigationItem(id: 'ledger', title: 'Finance Ledger', icon: Icons.attach_money, category: 'personal'),
          const NavigationItem(id: 'expense_analyser', title: 'Expense Analyzer', icon: Icons.wallet, category: 'personal'),
          const NavigationItem(id: 'sleep_log', title: 'Sleep Logger', icon: Icons.bedtime, category: 'personal'),
          const NavigationItem(id: 'water_ticker', title: 'Water Ticker', icon: Icons.water_drop, category: 'personal'),
          const NavigationItem(id: 'workout', title: 'Workout Planner', icon: Icons.fitness_center, category: 'personal'),
        ],
      ),
    ];

    emit(state.copyWith(
      status: NavigationStatus.success,
      categories: categories,
      filteredCategories: categories,
      searchQuery: '',
    ));
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<NavigationState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredCategories: state.categories,
      ));
      return;
    }

    final filtered = state.categories.map((category) {
      final matchingItems = category.items
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
      return category.copyWith(items: matchingItems);
    }).where((category) => category.items.isNotEmpty).toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredCategories: filtered,
    ));
  }

  void _onToggleCategoryCollapse(
    ToggleCategoryCollapseEvent event,
    Emitter<NavigationState> emit,
  ) {
    final categories = state.categories.map((c) {
      if (c.id == event.categoryId) {
        return c.copyWith(isCollapsed: !c.isCollapsed);
      }
      return c;
    }).toList();

    final filtered = state.filteredCategories.map((c) {
      if (c.id == event.categoryId) {
        return c.copyWith(isCollapsed: !c.isCollapsed);
      }
      return c;
    }).toList();

    emit(state.copyWith(
      categories: categories,
      filteredCategories: filtered,
    ));
  }
}
