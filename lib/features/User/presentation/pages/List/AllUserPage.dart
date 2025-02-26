import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/features/User/presentation/widget/list/sectionHeader.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/list/sectionListOfUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AllUserList extends ConsumerWidget {
  const AllUserList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String ans = "ans".tr;
    return ThemeSwitchingArea(
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Liste des utilisateurs'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                    child: FaIcon(FontAwesomeIcons.chevronLeft, size: 20))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer(builder: (context, ref, child) {
          final notifier = ref.watch(allUserListStateNotifier);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SectionHeader(
                showFilterOption: true,
                nameSearch: notifier.nameSearch,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (notifier.nameSearch != "" && notifier.isFilter == false)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liste des utilisateurs'.tr.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                          )
                        ],
                      ),
                    if (notifier.nameSearch != "" && notifier.isFilter == true)
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtre'.tr.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: 24,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            )
                          ],
                        ),
                      ),
                    if (notifier.nameSearch == "" && notifier.isFilter == true)
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtre'.tr.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: 24,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                            )
                          ],
                        ),
                      ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notifier.pays != "")
                              Text(notifier.pays.toUpperCase()),
                            if (notifier.pays != "")
                              SizedBox(
                                width: 5,
                              ),
                            if (notifier.nationalite != "" &&
                                notifier.pays != "")
                              Text('/'),
                            if (notifier.pays != "")
                              SizedBox(
                                width: 5,
                              ),
                            if (notifier.nationalite != "")
                              Text(notifier.nationalite.toUpperCase()),
                            if (notifier.nationalite != "")
                              SizedBox(
                                width: 5,
                              ),
                            if ((notifier.nationalite != "" ||
                                    notifier.pays != "") &&
                                notifier.sexe != "")
                              Text('/'),
                            if (notifier.sexe != "")
                              SizedBox(
                                width: 5,
                              ),
                            if (notifier.sexe != "")
                              Text(notifier.sexe.tr.toUpperCase()),
                            if (notifier.sexe != "")
                              SizedBox(
                                width: 5,
                              ),
                            if (notifier.isFilter == true) Text('/'),
                            if (notifier.sexe != "")
                              SizedBox(
                                width: 5,
                              ),
                            if (notifier.isFilter == true)
                              Text(
                                  '${notifier.rangeOfageDebutAndFin.start.toInt()} - ${notifier.rangeOfageDebutAndFin.end.toInt()} $ans'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: SectonListOfUser(onTap: () {}, notifier: notifier))
            ],
          );
        }),
      ),
    );
  }
}
