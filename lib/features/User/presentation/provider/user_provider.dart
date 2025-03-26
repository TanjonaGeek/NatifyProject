import 'package:natify/features/User/presentation/provider/state/auth_notifier_user.dart';
import 'package:natify/features/User/presentation/provider/state/auth_state_user.dart';
import 'package:natify/features/User/presentation/provider/state/info_notifer_user.dart';
import 'package:natify/features/User/presentation/provider/state/info_state_user.dart';
import 'package:natify/features/User/presentation/provider/state/list_notifier_user.dart';
import 'package:natify/features/User/presentation/provider/state/list_state_user.dart';
import 'package:natify/features/User/presentation/provider/state/maps_notifier_user.dart';
import 'package:natify/features/User/presentation/provider/state/maps_state_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natify/features/User/presentation/provider/state/marketplace_notifier.dart';
import 'package:natify/features/User/presentation/provider/state/marketplace_state.dart';

final userAuthStateNotifier =
    AutoDisposeStateNotifierProvider<AuthNotifier, AuthState>(
        (ref) => AuthNotifier());
final allUserListStateNotifier =
    StateNotifierProvider<AllUserListhNotifier, AllUserListState>(
        (ref) => AllUserListhNotifier());
final infoUserStateNotifier =
    StateNotifierProvider<InfoNotifierUser, InfoStateUser>(
        (ref) => InfoNotifierUser());
final mapsUserStateNotifier =
    StateNotifierProvider<MapsUserhNotifier, MapsUserState>(
        (ref) => MapsUserhNotifier(ref));
final marketPlaceUserStateNotifier =
    StateNotifierProvider<MarketplaceUserNotifier, MarketplaceUserState>(
        (ref) => MarketplaceUserNotifier(ref));
