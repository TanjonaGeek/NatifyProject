import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/features/Chat/data/datasources/local/data_source_chat.dart';
import 'package:natify/features/Chat/data/datasources/local/data_sources_chat_impl..dart';
import 'package:natify/features/Chat/data/repositories/chat_repositorie_impl.dart';
import 'package:natify/features/Chat/domaine/repositories/chat_repository.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseAppearMessageInList.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseBloqueMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseChangeThemeMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseDebloqueMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseDeleteMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseGetStatusBloqueOnChat.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseGetStatusTyping.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseGetStatusbloque.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseSendMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseTypingIndicator.dart';
import 'package:natify/features/Chat/domaine/usecases/useCaseUnreadMessage.dart';
import 'package:natify/features/Chat/domaine/usecases/useCasegetStatusOnline.dart';
import 'package:natify/features/Chat/domaine/usecases/useCasesReactMessage.dart';
import 'package:natify/features/Storie/data/datasources/local/data_source_story.dart';
import 'package:natify/features/Storie/data/datasources/local/data_sources_story_impl..dart';
import 'package:natify/features/Storie/data/repositories/story_repositorie_impl.dart';
import 'package:natify/features/Storie/domaine/repositories/storie_repository.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseCreateStorie.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseDeleteStory.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseListStory.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseReactStory.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseReplyStorie.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseSendNotificationFollowers.dart';
import 'package:natify/features/Storie/domaine/usecases/useCaseViewStorie.dart';
import 'package:natify/features/User/data/datasources/local/data_source_user.dart';
import 'package:natify/features/User/data/datasources/local/data_sources_user_impl..dart';
import 'package:natify/features/User/data/repositories/user_repositorie_impl.dart';
import 'package:natify/features/User/domaine/repositories/user_repository.dart';
import 'package:natify/features/User/domaine/usecases/useCasUpdateStatusAutorisation.dart';
import 'package:natify/features/User/domaine/usecases/useCaseAbonner.dart';
import 'package:natify/features/User/domaine/usecases/useCaseAddReceiveNotificatonByUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseCreateHighLight.dart';
import 'package:natify/features/User/domaine/usecases/useCaseDeleteAccount.dart';
import 'package:natify/features/User/domaine/usecases/useCaseDesabonner.dart';
import 'package:natify/features/User/domaine/usecases/useCaseEditerHiglight.dart';
import 'package:natify/features/User/domaine/usecases/useCaseGetInfoUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseIsFillUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseModifierPhotoProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCaseMyInfoData.dart';
import 'package:natify/features/User/domaine/usecases/useCaseRemoveReceiveNotificatonByUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSaveVersionAppUseByUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSendNotificationHighLightFollowers.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignIn.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignOut.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignUp.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSignalProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSupprimerHighLight.dart';
import 'package:natify/features/User/domaine/usecases/useCaseSuprrimerPhotoProfiles.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateAllInfoUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateDistancePosition.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateInfoInAccount.dart';
import 'package:natify/features/User/domaine/usecases/useCaseUpdateStatusUser.dart';
import 'package:natify/features/User/domaine/usecases/useCaseVoirHighLight.dart';
import 'package:natify/features/User/domaine/usecases/useCasegetUserTokenNotification.dart';
import 'package:natify/features/User/domaine/usecases/useCasesGetPhotoPrrofile.dart';
import 'package:natify/features/User/domaine/usecases/useCasesGetAllPhotoProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCasesGetPartPhotoProfile.dart';
import 'package:natify/features/User/domaine/usecases/useCasesHasStorie.dart';
import 'package:natify/features/User/domaine/usecases/useCasesUpdateOnSeeNotification.dart';
import 'package:natify/features/User/domaine/usecases/useCasesVisiteProfile.dart';
import 'package:get_it/get_it.dart';

final injector = GetIt.instance;

Future<void> initializationDepencies() async {
  injector
      .registerLazySingleton<NotificationService>(() => NotificationService());
  //DataSources User injection de dependance
  injector.registerFactory<DataSourceUser>(() => DataSourceUserImpl());
  injector.registerFactory<DataSourceStorie>(() => DataSourceStorieImpl());
  injector.registerFactory<DataSourceChat>(() => DataSourceChatImpl());

  // injector.registerLazySingleton<NotificationService>(() => NotificationService());
  //Repositories User injection de dependance
  injector.registerFactory<UserRepository>(() => UserRepositoryImpl(
        dataSourceUser: injector.get<DataSourceUser>(),
      ));
  injector.registerFactory<StorieRepository>(() => StorieRepositoryImpl(
        dataSourceStorie: injector.get<DataSourceStorie>(),
      ));
  injector.registerFactory<ChatRepository>(() => ChatRepositoryImpl(
        dataSourceChat: injector.get<DataSourceChat>(),
      ));

  //UseCases User injection de dependance
  injector.registerFactory<UseCaseSignIn>(
      () => UseCaseSignIn(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseSignUp>(
      () => UseCaseSignUp(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseSignOut>(
      () => UseCaseSignOut(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseGetToken>(
      () => UseCaseGetToken(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseDeleteAccount>(() =>
      UseCaseDeleteAccount(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseIsFillUser>(
      () => UseCaseIsFillUser(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseUpdateInfoUser>(() =>
      UseCaseUpdateInfoUser(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseGetInfoUser>(
      () => UseCaseGetInfoUser(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseGetAllPhotoProfile>(() =>
      UseCaseGetAllPhotoProfile(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseGetPartPhotoProfile>(() =>
      UseCaseGetPartPhotoProfile(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseUpdateAllInfoUser>(() =>
      UseCaseUpdateAllInfoUser(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseVisiteProfileUser>(() =>
      UseCaseVisiteProfileUser(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseGetPhotoProfile>(() =>
      UseCaseGetPhotoProfile(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseCreateHighLight>(() =>
      UseCaseCreateHighLight(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseVoirHighLight>(() =>
      UseCaseVoirHighLight(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseSupprimerHighLight>(() =>
      UseCaseSupprimerHighLight(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseEditereHighLight>(() =>
      UseCaseEditereHighLight(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseAbonner>(
      () => UseCaseAbonner(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseDesabonner>(
      () => UseCaseDesabonner(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseMyInfoData>(
      () => UseCaseMyInfoData(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseUpdateStatusUser>(() =>
      UseCaseUpdateStatusUser(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseUpdateDistancePosition>(() =>
      UseCaseUpdateDistancePosition(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseCheckHasStorie>(() =>
      UseCaseCheckHasStorie(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseUpdateStatusOnSeeNotification>(() =>
      UseCaseUpdateStatusOnSeeNotification(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseUpdateStatusAutorisation>(() =>
      UseCaseUpdateStatusAutorisation(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseSendNotificationHighLightFollowers>(() =>
      UseCaseSendNotificationHighLightFollowers(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseSignalProfile>(() =>
      UseCaseSignalProfile(userRepository: injector.get<UserRepository>()));
  injector.registerFactory<useCaseAddReceiveNotificatonByUser>(() =>
      useCaseAddReceiveNotificatonByUser(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<useCaseRemoveReceiveNotificatonByUser>(() =>
      useCaseRemoveReceiveNotificatonByUser(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<useCaseSaveVersionUseByUser>(() =>
      useCaseSaveVersionUseByUser(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseSupprimerPhotoProfiles>(() =>
      UseCaseSupprimerPhotoProfiles(
          userRepository: injector.get<UserRepository>()));
  injector.registerFactory<UseCaseModifierPhotoProfiles>(() =>
      UseCaseModifierPhotoProfiles(
          userRepository: injector.get<UserRepository>()));

  injector.registerFactory<UseCaseGetStorie>(() =>
      UseCaseGetStorie(storieRepository: injector.get<StorieRepository>()));
  injector.registerFactory<UseCaseViewStorie>(() =>
      UseCaseViewStorie(storieRepository: injector.get<StorieRepository>()));
  injector.registerFactory<UseCaseReactStorie>(() =>
      UseCaseReactStorie(storieRepository: injector.get<StorieRepository>()));
  injector.registerFactory<UseCaseCreateStorie>(() =>
      UseCaseCreateStorie(storieRepository: injector.get<StorieRepository>()));
  injector.registerFactory<UseCaseDeleteStorie>(() =>
      UseCaseDeleteStorie(storieRepository: injector.get<StorieRepository>()));
  injector.registerFactory<UseCaseReplyStorie>(() =>
      UseCaseReplyStorie(storieRepository: injector.get<StorieRepository>()));
  injector.registerFactory<UseCaseSendNotificationFollowers>(() =>
      UseCaseSendNotificationFollowers(
          storieRepository: injector.get<StorieRepository>()));

  injector.registerFactory<UseCaseBloqueMessage>(() =>
      UseCaseBloqueMessage(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseDebloqueMessage>(() =>
      UseCaseDebloqueMessage(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseDeleteMessage>(() =>
      UseCaseDeleteMessage(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseSendMessage>(
      () => UseCaseSendMessage(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseTypingIndicator>(() =>
      UseCaseTypingIndicator(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseStatusTyping>(() =>
      UseCaseStatusTyping(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseStatusOnline>(() =>
      UseCaseStatusOnline(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseUnreadMessage>(() =>
      UseCaseUnreadMessage(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseGetStatusBloque>(() =>
      UseCaseGetStatusBloque(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseGetStatusBloqueOnChat>(() =>
      UseCaseGetStatusBloqueOnChat(
          chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseDesappearMessageInlist>(() =>
      UseCaseDesappearMessageInlist(
          chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseReactMessage>(() =>
      UseCaseReactMessage(chatRepository: injector.get<ChatRepository>()));
  injector.registerFactory<UseCaseChangeThemeMessage>(() =>
      UseCaseChangeThemeMessage(
          chatRepository: injector.get<ChatRepository>()));
}
