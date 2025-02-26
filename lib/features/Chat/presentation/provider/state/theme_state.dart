import 'package:equatable/equatable.dart';

enum ThemeConcreteState { initial, loading, loaded, failure }

class ThemeState extends Equatable {
  final ThemeConcreteState state;
  final String tokenUpdateTheme;

  const ThemeState({
    this.state = ThemeConcreteState.initial,
    this.tokenUpdateTheme = '',
  });

  const ThemeState.initial({
    this.state = ThemeConcreteState.initial,
    this.tokenUpdateTheme = '',
  });

  ThemeState copyWith({
    ThemeConcreteState? state,
    String? tokenUpdateTheme,
  }) {
    return ThemeState(
      state: state ?? this.state,
      tokenUpdateTheme: tokenUpdateTheme ?? this.tokenUpdateTheme,
    );
  }

  @override
  List<Object?> get props => [state, tokenUpdateTheme];
}
