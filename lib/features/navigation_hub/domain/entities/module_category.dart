import 'package:equatable/equatable.dart';
import 'navigation_item.dart';

class ModuleCategory extends Equatable {
  final String id;
  final String name;
  final List<NavigationItem> items;
  final bool isCollapsed;

  const ModuleCategory({
    required this.id,
    required this.name,
    required this.items,
    this.isCollapsed = false,
  });

  ModuleCategory copyWith({
    String? id,
    String? name,
    List<NavigationItem>? items,
    bool? isCollapsed,
  }) {
    return ModuleCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }

  @override
  List<Object?> get props => [id, name, items, isCollapsed];
}
