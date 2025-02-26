import 'package:equatable/equatable.dart';

class HighlightEntity extends Equatable{
  final List<Map<String, dynamic>>? data;
  final String? profilePic;
  final List<Map<String, dynamic>>? QuivoirCollection;
  final String? type;

  const HighlightEntity({
    required this.data,
    required this.profilePic,
    required this.QuivoirCollection,
    required this.type,
  });

  @override
  List < Object ? > get props {
    return [
    data,
    profilePic,
    QuivoirCollection,
    type,
    ];
  }
}