import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:equatable/equatable.dart';

enum InfoUserConcreteState { initial, loading, loaded, failure }

class InfoStateUser extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool isReload;
  final bool isCompletedCheck;
  final String IsFilled;
  final List<UserEntity> MyOwnData;
  final UserModel? MydataPersiste;
  final List<Map<String, dynamic>> photoProfile;
  final List<Map<String, dynamic>> partphotoProfile;
  final InfoUserConcreteState state;

  const InfoStateUser(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isReload = false,
      this.isCompletedCheck = false,
      this.IsFilled = '',
      this.MyOwnData = const [],
      this.MydataPersiste,
      this.photoProfile = const [],
      this.partphotoProfile = const [],
      this.state = InfoUserConcreteState.initial});

  const InfoStateUser.initial(
      {this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.isReload = false,
      this.isCompletedCheck = false,
      this.IsFilled = "",
      this.MyOwnData = const [],
      this.MydataPersiste,
      this.photoProfile = const [],
      this.partphotoProfile = const [],
      this.state = InfoUserConcreteState.initial});

  InfoStateUser copyWith({
    bool? hasData,
    String? message,
    bool? isLoading,
    bool? isReload,
    bool? isCompletedCheck,
    String? IsFilled,
    List<UserEntity>? MyOwnData,
    UserModel? MydataPersiste,
    List<Map<String, dynamic>>? photoProfile,
    List<Map<String, dynamic>>? partphotoProfile,
    InfoUserConcreteState? state,
  }) {
    return InfoStateUser(
        hasData: hasData ?? this.hasData,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isReload: isReload ?? this.isReload,
        isCompletedCheck: isCompletedCheck ?? this.isCompletedCheck,
        IsFilled: IsFilled ?? this.IsFilled,
        MyOwnData: MyOwnData ?? this.MyOwnData,
        MydataPersiste: MydataPersiste ?? this.MydataPersiste,
        photoProfile: photoProfile ?? this.photoProfile,
        partphotoProfile: partphotoProfile ?? this.partphotoProfile,
        state: state ?? this.state);
  }

  @override
  List<Object?> get props => [
        hasData,
        message,
        isLoading,
        isReload,
        isCompletedCheck,
        IsFilled,
        MyOwnData,
        MydataPersiste,
        photoProfile,
        partphotoProfile,
        state
      ];
}
