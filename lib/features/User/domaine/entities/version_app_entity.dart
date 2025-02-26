import 'package:equatable/equatable.dart';

class VersionAppEntity extends Equatable{
  final String? numeroVersion;

  const VersionAppEntity({
    required this.numeroVersion,
  });

  @override
  List < Object ? > get props {
    return [
    numeroVersion,
    ];
  }
}