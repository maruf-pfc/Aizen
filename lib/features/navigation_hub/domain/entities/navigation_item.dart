import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

class NavigationItem extends Equatable {
  final String id;
  final String title;
  final IconData icon;
  final String category;
  final String? badge;

  const NavigationItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    this.badge,
  });

  @override
  List<Object?> get props => [id, title, icon, category, badge];
}
