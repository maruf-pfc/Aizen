import 'package:equatable/equatable.dart';
import '../../domain/entities/module_category.dart';

enum NavigationStatus { initial, loading, success, failure }

class NavigationState extends Equatable {
  final NavigationStatus status;
  final List<ModuleCategory> categories;
  final List<ModuleCategory> filteredCategories;
  final String searchQuery;
  final String? errorMessage;
  final int activeIndex;

  const NavigationState({
    this.status = NavigationStatus.initial,
    this.categories = const [],
    this.filteredCategories = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.activeIndex = 0,
  });

  NavigationState copyWith({
    NavigationStatus? status,
    List<ModuleCategory>? categories,
    List<ModuleCategory>? filteredCategories,
    String? searchQuery,
    String? errorMessage,
    int? activeIndex,
  }) {
    return NavigationState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        filteredCategories,
        searchQuery,
        errorMessage,
        activeIndex,
      ];
}
