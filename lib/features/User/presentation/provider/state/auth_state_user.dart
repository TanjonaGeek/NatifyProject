import 'package:equatable/equatable.dart';

enum AuthConcreteState { initial, loading, loaded, failure }

class AuthState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool isLogout;
  final String tokenReload;
  final AuthConcreteState state;

  const AuthState(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isLogout = false,
      this.tokenReload = '',
      this.state = AuthConcreteState.initial});

  const AuthState.initial(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isLogout = false,
      this.tokenReload = '',
      this.state = AuthConcreteState.initial});

  AuthState copyWith(
      {bool? hasData,
      String? message,
      bool? isLoading,
      bool? isLogout,
      String? tokenReload,
      AuthConcreteState? state}) {
    return AuthState(
        hasData: hasData ?? this.hasData,
        isLoading: isLoading ?? this.isLoading,
        isLogout: isLogout ?? this.isLogout,
        tokenReload: tokenReload ?? this.tokenReload,
        state: state ?? this.state);
  }

  @override
  List<Object?> get props => [hasData, isLoading, isLogout, tokenReload, state];
}
