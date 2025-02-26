import 'package:natify/features/User/domaine/entities/user_entities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AllUserListConcreteState { initial, loading, loaded, failure }

class AllUserListState extends Equatable {
  final bool hasData;
  final String message;
  final bool isLoading;
  final bool IsTypeInSearchBar;
  final RangeValues rangeOfageDebutAndFin;
  final String sexe;
  final String nationalite;
  final String pays;
  final String flag;
  final String nameSearch;
  final bool isFilter;
  final Map<dynamic,bool> messageOnDelete;
  final List<Map<String, String>> nationaliteGroup;
  final List<String> nationaliteGroupSansFlag;
  final AllUserListConcreteState state;

  const AllUserListState({
      this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.IsTypeInSearchBar = false, 
      this.rangeOfageDebutAndFin = const RangeValues(14,90),  
      this.sexe = "", 
      this.nationalite = "", 
      this.pays = "",
      this.flag = "",
      this.nameSearch = '',
      this.isFilter = false,
      this.messageOnDelete = const {},
      this.nationaliteGroup = const [],
      this.nationaliteGroupSansFlag = const [],
      this.state = AllUserListConcreteState.initial
      });

  const AllUserListState.initial(
      {
      this.hasData = false,
      this.message = '',
      this.isLoading = false,
      this.IsTypeInSearchBar = false, 
      this.rangeOfageDebutAndFin = const RangeValues(14,90), 
      this.sexe = "", 
      this.nationalite = "", 
      this.pays = "",
      this.flag = "",
      this.nameSearch = '',
      this.isFilter = false,
      this.messageOnDelete = const {},
      this.nationaliteGroup = const [],
      this.nationaliteGroupSansFlag = const [],
      this.state = AllUserListConcreteState.initial
      });

  AllUserListState copyWith({
      bool? hasData,
      String? message,
      bool? isLoading,
      bool? IsTypeInSearchBar,
      RangeValues? rangeOfageDebutAndFin,
      String? sexe,
      String? nationalite,
      String? pays,
      String? flag,
      List<UserEntity>? listAlluser,
      List<UserEntity>? listAlluserTmp,
      List<UserEntity>? listAlluserDisplay,
      bool? hasMore,
      String? nameSearch,
      bool? isFilter,
      Map<dynamic,bool>? messageOnDelete,
      List<Map<String, String>>? nationaliteGroup,
      List<String>? nationaliteGroupSansFlag,
      AllUserListConcreteState? state,
  }) {
    return AllUserListState(
        hasData: hasData ?? this.hasData,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        IsTypeInSearchBar: IsTypeInSearchBar ?? this.IsTypeInSearchBar,
        rangeOfageDebutAndFin: rangeOfageDebutAndFin ?? this.rangeOfageDebutAndFin,
        sexe: sexe ?? this.sexe,
        nationalite: nationalite ?? this.nationalite,
        pays: pays ?? this.pays,
        flag: flag ?? this.flag,
        isFilter: isFilter ?? this.isFilter,
        nameSearch: nameSearch ?? this.nameSearch,
        messageOnDelete: messageOnDelete ?? this.messageOnDelete,
        nationaliteGroup: nationaliteGroup ?? this.nationaliteGroup,
        nationaliteGroupSansFlag: nationaliteGroupSansFlag ?? this.nationaliteGroupSansFlag,
        state: state ?? this.state
        );
  }

  @override
  List<Object?> get props => [hasData, message,isLoading , IsTypeInSearchBar,rangeOfageDebutAndFin,sexe,nationalite,pays,flag,nameSearch,isFilter,messageOnDelete,nationaliteGroup,nationaliteGroupSansFlag,state];
}
