import 'dart:async';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/domaine/usecases/useCasesHasStorie.dart';
import 'package:natify/features/User/presentation/provider/state/list_state_user.dart';
import 'package:natify/injector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllUserListhNotifier extends StateNotifier<AllUserListState> {
  Timer? _debounce;
  final UseCaseCheckHasStorie _checkStorieUserUseCase =
      injector.get<UseCaseCheckHasStorie>();
  AllUserListhNotifier() : super(const AllUserListState.initial());

  bool get isFetching => state.state != AllUserListConcreteState.loading;

  Future<Map<String, dynamic>> checkifHasStorie(String uid) async {
    try {
      return await _checkStorieUserUseCase
          .call(uid)
          .timeout(Duration(seconds: 5));
    } catch (e) {
      print("Erreur dans checkifHasStorie: $e");
      return {'hasStorie': false}; // Retour par défaut en cas d'échec
    }
  }

  // Charger les messages supprimés depuis SharedPreferences
  Future<void> loadDeletedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedMessages = prefs.getStringList('deletedMessages') ?? [];
    final deletedMap = {for (var e in deletedMessages) e: true};
    state = state.copyWith(
      messageOnDelete: deletedMap,
    );
  }

  // Ajouter un message supprimé à l'état
  Future<void> addDeletedMessage(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedMessages = prefs.getStringList('deletedMessages') ?? [];
    deletedMessages.add(messageId);
    await prefs.setStringList('deletedMessages', deletedMessages);
    state = state.copyWith(
      messageOnDelete: {...state.messageOnDelete, messageId: true},
    );
  }

  // Supprimer un message de l'état
  Future<void> removeDeletedMessage(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedMessages = prefs.getStringList('deletedMessages') ?? [];
    deletedMessages.remove(messageId);
    await prefs.setStringList('deletedMessages', deletedMessages);

    state = state.copyWith(
      messageOnDelete: {...state.messageOnDelete, messageId: true},
    );
  }

  // Supprimer un message de l'état
  Future<void> removeDeleted() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedMessages = prefs.getStringList('deletedMessages') ?? [];
    await prefs.setStringList('deletedMessages', []);
  }

  Future<void> getAllUserBySearchName(String searchQuery) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    try {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        showCustomSnackBar("Pas de connexion internet");
        return;
      }
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        state = state.copyWith(
          nameSearch: searchQuery,
        );
      });
    } catch (e) {
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }

  Future<void> SetAge({required RangeValues rangeOfageDebutAndFin}) async {
    state = state.copyWith(
      rangeOfageDebutAndFin: rangeOfageDebutAndFin,
    );
  }

  Future<void> SetIsTyping({required bool typing}) async {
    state = state.copyWith(
      IsTypeInSearchBar: typing,
    );
  }

  Future<void> SetSexe({required String sexe}) async {
    state = state.copyWith(sexe: sexe);
  }

  Future<void> SetNationalite({required String nationalite}) async {
    state = state.copyWith(nationalite: nationalite);
  }

  Future<void> SetPays({required String pays}) async {
    state = state.copyWith(pays: pays);
  }

  Future<void> SetFlag({required String flag}) async {
    state = state.copyWith(flag: flag);
  }

  SetUpdateFieldToFilter(
      {required List<String> nationaliteGroupSansFlag,
      required List<Map<String, String>> nationaliteGroup,
      required String sexe,
      required String flag,
      required String nationalite,
      required String pays,
      required RangeValues rangeOfageDebutAndFin}) async {
    state = state.copyWith(
        flag: flag,
        sexe: sexe == "tout" ? '' : sexe,
        nationalite: nationalite,
        pays: pays,
        isFilter: true,
        rangeOfageDebutAndFin: rangeOfageDebutAndFin,
        nationaliteGroup: nationaliteGroup,
        nationaliteGroupSansFlag: nationaliteGroupSansFlag);
  }

  Future<void> ResetFilter() async {
    state = state.copyWith(
        rangeOfageDebutAndFin: RangeValues(14, 90),
        sexe: '',
        pays: '',
        flag: '',
        nationalite: '',
        nameSearch: '',
        nationaliteGroup: [],
        nationaliteGroupSansFlag: [],
        isFilter: false);
  }
}
