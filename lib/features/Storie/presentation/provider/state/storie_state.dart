import 'package:natify/features/Storie/domaine/entities/storie_entities.dart';
import 'package:equatable/equatable.dart';

enum StorieListConcreteState { initial, loading, loaded, failure }

class StorieState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool isMe;
  final bool hasMore;
  final List<StorieEntity> listAllStory;
  final List<StorieEntity> OwnStory;
  final bool isDescoveryStorie;
  final StorieListConcreteState state;

  const StorieState(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isMe = true,
      this.hasMore = false,
      this.listAllStory = const [],
      this.OwnStory = const [],
      this.isDescoveryStorie = false,
      this.state = StorieListConcreteState.initial});

  const StorieState.initial(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isMe = true,
      this.hasMore = false,
      this.listAllStory = const [],
      this.OwnStory = const [],
      this.isDescoveryStorie = false,
      this.state = StorieListConcreteState.initial});

  StorieState copyWith({
    bool? hasData,
    String? message,
    bool? isLoading,
    bool? isMe,
    bool? hasMore,
    List<StorieEntity>? listAllStory,
    List<StorieEntity>? OwnStory,
    bool? isDescoveryStorie,
    StorieListConcreteState? state,
  }) {
    return StorieState(
        hasData: hasData ?? this.hasData,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isMe: isMe ?? this.isMe,
        hasMore: hasMore ?? this.hasMore,
        listAllStory: listAllStory ?? this.listAllStory,
        OwnStory: OwnStory ?? this.OwnStory,
        isDescoveryStorie: isDescoveryStorie ?? this.isDescoveryStorie,
        state: state ?? this.state);
  }

  @override
  List<Object?> get props => [
        hasData,
        message,
        isLoading,
        isMe,
        hasMore,
        listAllStory,
        OwnStory,
        isDescoveryStorie,
        state
      ];
}
