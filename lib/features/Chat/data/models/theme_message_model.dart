import 'package:natify/features/Chat/domaine/entities/theme_message_entities.dart';

class ThemeMessageModel extends ThemeMessageEntity {
  const ThemeMessageModel({super.themeMessage});

  factory ThemeMessageModel.fromJson(Map<String, dynamic> map) {
    return ThemeMessageModel(
      themeMessage: List<Map<String, String>>.from(map['themeMessage']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMessage': themeMessage,
    };
  }

  factory ThemeMessageModel.fromEntity(ThemeMessageEntity entity) {
    return ThemeMessageModel(
      themeMessage: entity.themeMessage,
    );
  }

  ThemeMessageEntity toEntity() {
    return ThemeMessageEntity(
      themeMessage: themeMessage,
    );
  }
}
