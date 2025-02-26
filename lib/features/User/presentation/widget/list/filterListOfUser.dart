import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/widget/nationaliteListPage.dart';
import 'package:natify/core/utils/widget/paysListPage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/list/filterOption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class FilterPage extends ConsumerStatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  String sexe = "";
  String nationalite = "";
  String pays = "";
  String flag = "";
  String ans = "ans".tr;
  RangeValues age = RangeValues(14, 90);
  List<Map<String, String>> nationaliteGroup = [];
  List<String> nationaliteGroupSansFlag = [];
  List<Map<String, String>> listPaysAnNationalite =
      Helpers.ListeNationaliteHelper;

  void _openNationalityPage() async {
    List<Map<String, String>> nationaliteGroups = List.from(nationaliteGroup);
    List<String> nationaliteGroupsSansFlags =
        List.from(nationaliteGroupSansFlag);
    final selectedNationality = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NationaliteListPage(listNationalite: listPaysAnNationalite),
      ),
    );
    if (selectedNationality != null) {
      nationaliteGroups.add({
        'nationalite': selectedNationality['nationality'] ?? '',
        'flag': selectedNationality['flagCode'] ?? ''
      });
      nationaliteGroupsSansFlags.add(selectedNationality['nationality']);
      setState(() {
        nationaliteGroup = nationaliteGroups;
        nationaliteGroupSansFlag = nationaliteGroupsSansFlags;
        flag = selectedNationality['flagCode'] ?? '';
        nationalite = selectedNationality['nationality'] ?? '';
      });
    }
  }

  void _openPaysPage() async {
    final selectedPays = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaysListPage(listPays: listPaysAnNationalite),
      ),
    );
    if (selectedPays != null) {
      setState(() {
        pays = selectedPays['country'] ?? '';
      });
    }
  }

  void ResetFilter() {
    setState(() {
      sexe = '';
      nationalite = '';
      pays = '';
      flag = '';
      age = RangeValues(14, 90);
      nationaliteGroup = [];
      nationaliteGroupSansFlag = [];
    });
    ref.read(allUserListStateNotifier.notifier).ResetFilter();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final notifier = ref.read(allUserListStateNotifier);
    setState(() {
      sexe = notifier.sexe;
      nationalite = notifier.nationalite;
      pays = notifier.pays;
      flag = notifier.flag;
      age = notifier.rangeOfageDebutAndFin;
      nationaliteGroup = notifier.nationaliteGroup;
      nationaliteGroupSansFlag = notifier.nationaliteGroupSansFlag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Filtre'.tr,
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
            actions: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.solidTrashCan, size: 20),
                onPressed: () => ResetFilter(),
              ),
            ],
          ),
          body: Consumer(builder: ((context, ref, child) {
            return Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: ListView(
                children: [
                  Text(
                    "Affinez vos résultats en appliquant des filtres spécifiques pour trouver les utilisateurs qui correspondent à vos critères."
                        .tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade500,
                    thickness: 0.2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sexe'.tr,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  FilterOption(
                    checkIfAge: false,
                    selectedOptions: Helpers.genders,
                    selectedItem: sexe,
                    content: SizedBox(),
                    onSelected: (String? selected) {
                      setState(() {
                        sexe = selected.toString();
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.grey.shade500,
                    thickness: 0.2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nationalité'.tr,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () => _openNationalityPage(),
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Center(
                                child: FaIcon(FontAwesomeIcons.add,
                                    size: 15, color: Colors.black))),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 8.0, // Espacement horizontal entre les éléments
                    runSpacing: 8.0, // Espacement vertical entre les lignes
                    children: nationaliteGroup.map((item) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            nationaliteGroup.removeWhere((element) =>
                                element['nationalite'] == item['nationalite']);
                            nationaliteGroupSansFlag
                                .remove(item['nationalite']);
                          });
                        },
                        child: Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${item['flag']} ${item['nationalite']}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              SizedBox(width: 4),
                              FaIcon(FontAwesomeIcons.close,
                                  size: 18, color: Colors.white),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          backgroundColor: kPrimaryColor,
                          side: BorderSide(style: BorderStyle.none),
                          labelPadding: EdgeInsets.only(
                              top: 2, left: 6, right: 6, bottom: 2),
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pays'.tr,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () => _openPaysPage(),
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Center(
                                child: FaIcon(FontAwesomeIcons.add,
                                    size: 15, color: Colors.black))),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FilterOption(
                      checkIfAge: false,
                      content: pays == ""
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    pays = "";
                                  });
                                },
                                child: Wrap(spacing: 8.0, children: [
                                  Chip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          pays,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        SizedBox(width: 4),
                                        FaIcon(FontAwesomeIcons.close,
                                            size: 18, color: Colors.white)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    backgroundColor: kPrimaryColor,
                                    side: BorderSide(style: BorderStyle.none),
                                    labelPadding: EdgeInsets.only(
                                        top: 2, left: 6, right: 6, bottom: 2),
                                  )
                                ]),
                              ),
                            )),
                  Divider(
                    color: Colors.grey.shade500,
                    thickness: 0.2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Âge'.tr,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "${age.start.toInt()} ${age.end.toInt()} $ans",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FilterOption(
                      checkIfAge: true,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RangeSlider(
                              min: 14,
                              max: 90,
                              activeColor: kPrimaryColor,
                              values: age,
                              onChanged: (value) {
                                setState(() {
                                  age = value;
                                });
                              }),
                        ],
                      )),
                ],
              ),
            );
          })),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildActionButtons()),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          if (mounted) {
            ref.read(allUserListStateNotifier.notifier).SetUpdateFieldToFilter(
                nationaliteGroupSansFlag: nationaliteGroupSansFlag,
                nationaliteGroup: nationaliteGroup,
                sexe: sexe,
                flag: flag,
                nationalite: nationalite,
                pays: pays,
                rangeOfageDebutAndFin: age);
          }
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: kPrimaryColor,
        ),
        child: Text(
          'Trouver'.tr.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
