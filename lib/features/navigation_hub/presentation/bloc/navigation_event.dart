import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNavigationEvent extends NavigationEvent {
  const LoadNavigationEvent();
}

class SearchQueryChangedEvent extends NavigationEvent {
  final String query;

  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleCategoryCollapseEvent extends NavigationEvent {
  final String categoryId;

  const ToggleCategoryCollapseEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ChangeActiveIndexEvent extends NavigationEvent {
  final int index;
  const ChangeActiveIndexEvent(this.index);

  @override
  List<Object?> get props => [index];
}
