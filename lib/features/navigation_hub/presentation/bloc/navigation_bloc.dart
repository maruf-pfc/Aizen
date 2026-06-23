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
    on<ChangeActiveIndexEvent>(_onChangeActiveIndex);
  }

  void _onChangeActiveIndex(
    ChangeActiveIndexEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(activeIndex: event.index));
  }

  void _onLoadNavigation(
    LoadNavigationEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(status: NavigationStatus.loading));

    final categories = [
      ModuleCategory(
        id: 'active_features',
        name: 'Active Modules',
        items: [
          const NavigationItem(id: 'stopwatch', title: 'Stopwatch', icon: Icons.timer, category: 'active_features'),
          const NavigationItem(id: 'quick_tasks', title: 'Quick Tasks', icon: Icons.playlist_add_check, category: 'active_features'),
          const NavigationItem(id: 'device_specs', title: 'Device Specs', icon: Icons.info_outline, category: 'active_features'),
          const NavigationItem(id: 'app_blocker', title: 'Focus Guardian', icon: Icons.block, category: 'active_features'),
          const NavigationItem(id: 'habit_tracker', title: 'Habit Builder', icon: Icons.track_changes, category: 'active_features'),
        ],
      ),
      ModuleCategory(
        id: 'v1_5_modules',
        name: 'v1.5.0 Modules',
        items: [
          const NavigationItem(id: 'calculator', title: 'Scientific Calculator', icon: Icons.calculate, category: 'v1_5_modules', badge: 'New'),
          const NavigationItem(id: 'expense_tracker', title: 'Expense & Bills', icon: Icons.account_balance_wallet, category: 'v1_5_modules', badge: 'New'),
          const NavigationItem(id: 'clipboard_vault', title: 'Clipboard Vault', icon: Icons.content_paste, category: 'v1_5_modules', badge: 'New'),
          const NavigationItem(id: 'time_blocker', title: 'Day Planner', icon: Icons.view_agenda, category: 'v1_5_modules', badge: 'New'),
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
