import 'package:equatable/equatable.dart';

class UserPhotoEntity extends Equatable{
  final String? urlPhoto;
  final int? timeCreated;
  final String? type;

  const UserPhotoEntity({
    required this.urlPhoto,
    required this.timeCreated,
    required this.type,
  });

  @override
  List < Object ? > get props {
    return [
    urlPhoto,
    timeCreated,
    type,
    ];
  }
}