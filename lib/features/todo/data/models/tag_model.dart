import '../../domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel(super.name);

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory TagModel.fromEntity(Tag tag) {
    return TagModel(tag.name);
  }
}
