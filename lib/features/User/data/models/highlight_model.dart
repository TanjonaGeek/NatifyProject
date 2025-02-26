import 'package:natify/features/User/domaine/entities/highlight_entity.dart';

class HighLightModel extends HighlightEntity {
  const HighLightModel({
    super.data,
    super.profilePic,
    super.QuivoirCollection,
    super.type,
  });

  factory HighLightModel.fromJson(Map<String, dynamic> map) {
    return HighLightModel(
      data: map['data'] ?? '',
      profilePic: map['profilePic'] ?? '',
      QuivoirCollection:
          List<Map<String, dynamic>>.from(map['QuivoirCollection']),
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'profilePic': profilePic,
      'QuivoirCollection': QuivoirCollection,
      'type': type,
    };
  }
}
