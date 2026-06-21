import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String name;

  const Tag(this.name);

  @override
  List<Object?> get props => [name];
}
