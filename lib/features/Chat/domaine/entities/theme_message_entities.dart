import 'package:equatable/equatable.dart';

class ThemeMessageEntity extends Equatable {
  final List<Map<String, String>>? themeMessage;

  const ThemeMessageEntity({
    required this.themeMessage,
  });

  @override
  List<Object?> get props {
    return [themeMessage];
  }
}
