import 'dart:async';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/List/AllUserPage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class SectionHeader extends ConsumerStatefulWidget {
  final String nameSearch;
  final bool showFilterOption;

  const SectionHeader(
      {super.key, required this.nameSearch, required this.showFilterOption});

  @override
  ConsumerState<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends ConsumerState<SectionHeader> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _filterUsers(String value, WidgetRef ref) {
    _debounce = Timer(const Duration(milliseconds: 1300), () {
      ref
          .read(allUserListStateNotifier.notifier)
          .getAllUserBySearchName(_searchController.text.trim())
          .then((onValue) {
        ref.read(infoUserStateNotifier.notifier).refreshProfile();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nameSearch.isEmpty) {
      _searchController.clear();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 9),
      child: TextField(
        onTap: () {
          if (widget.showFilterOption == false) {
            ref.read(allUserListStateNotifier.notifier).ResetFilter();
            SlideNavigation.slideToPage(context, AllUserList());
          }
        },
        readOnly: widget.showFilterOption == false ? true : false,
        controller: _searchController,
        decoration: InputDecoration(
          filled: widget.showFilterOption == false ? true : false,
          fillColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 2.0,
            ),
          ),
          contentPadding: EdgeInsets.only(left: 25, top: 15, bottom: 15),
          hintText: 'Rechercher'.tr,
          hintStyle: TextStyle(
              fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        onChanged: (value) => _filterUsers(value, ref),
      ),
    );
  }
}
