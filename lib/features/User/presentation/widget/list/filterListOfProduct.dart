import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/widget/nationaliteListPage.dart';
import 'package:natify/core/utils/widget/paysListPage.dart';
import 'package:natify/features/User/presentation/pages/map/filterOption.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FilterProductPage extends ConsumerStatefulWidget {
  const FilterProductPage({super.key});

  @override
  _FilterProductPageState createState() => _FilterProductPageState();
}

class _FilterProductPageState extends ConsumerState<FilterProductPage> {
  String categorie = "";
  String nationalite = "";
  String pays = "";
  String flag = "";
  String ans = "ans".tr;
  String a = "à".tr;
  RangeValues prix = RangeValues(1, 10000);
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
      categorie = '';
      nationalite = '';
      pays = '';
      flag = '';
      prix = RangeValues(1, 10000);
      nationaliteGroup = [];
      nationaliteGroupSansFlag = [];
    });
    ref.read(mapsUserStateNotifier.notifier).ResetFilter();
  }

  Future<void> loadFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    String? loadedFlag = prefs.getString('flagMarket');
    String? loadedCategorie = prefs.getString('categorieMarket');
    String? loadedNationalite = prefs.getString('nationaliteMarket');
    String? loadedPays = prefs.getString('paysMarket');

    // Récupération et conversion des RangeValues
    String? rangeString = prefs.getString('rangeOfPrixDebutAndFinMarket');
    RangeValues loadedRangeOfPrixDebutAndFin = rangeString != null
        ? RangeValues(
            double.parse(rangeString.split(',')[0]),
            double.parse(rangeString.split(',')[1]),
          )
        : RangeValues(1, 10000); // Valeurs par défaut

    List<String>? loadedNationaliteGroupSansFlag =
        prefs.getStringList('nationaliteGroupSansFlagMarket');

    // Récupération et conversion de `nationaliteGroup` depuis JSON
    String? nationaliteGroupJson = prefs.getString('nationaliteGroupMarket');
    List<Map<String, String>> loadedNationaliteGroup =
        nationaliteGroupJson != null
            ? List<Map<String, String>>.from(
                jsonDecode(nationaliteGroupJson)
                    .map((e) => Map<String, String>.from(e)),
              )
            : [];

    // Mise à jour de l'état avec setState
    setState(() {
      flag = loadedFlag ?? '';
      categorie = loadedCategorie ?? '';
      nationalite = loadedNationalite ?? '';
      pays = loadedPays ?? '';
      prix = loadedRangeOfPrixDebutAndFin;
      nationaliteGroupSansFlag = loadedNationaliteGroupSansFlag ?? [];
      nationaliteGroup = loadedNationaliteGroup;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFilterPreferences();
  }

  String _currentCurrency = 'USD';

  // Taux de conversion
  final Map<String, double> _exchangeRates = {
    'EUR': 1,
    'USD': 1,
    'MGA': 5000, // 1 EUR = 5000 MGA (exemple)
  };

  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };

  double rate = 1.1;
  // Limites dynamiques du slider
  double _minLimit = 1;
  double _maxLimit = 10000;
  // Fonction pour changer la devise et ajuster les prix
  void _changeCurrency(String newCurrency) {
    double ratesOld = _exchangeRates[_currentCurrency]!;
    double ratesNew = _exchangeRates[newCurrency]!;
    double _minLimitNew = _minLimit / ratesOld * ratesNew;
    double _maxLimitNew = _maxLimit / ratesOld * ratesNew;
    setState(() {
      _currentCurrency = newCurrency;
      _minLimit = _minLimitNew;
      _maxLimit = _maxLimitNew;
      prix = RangeValues(
          prix.start * ratesNew / ratesOld, prix.end * ratesNew / ratesOld);
    });
    Navigator.pop(context); // Fermer l'AlertDialog
  }

  @override
  Widget build(BuildContext context) {
    // Convertit les valeurs en fonction de la devise
    String formatDevise = _exchangeFormat[_currentCurrency] ?? "en_US";
    String PrixDebutformatted =
        NumberFormat.currency(locale: formatDevise, symbol: '')
            .format(prix.start);
    String PrixFinformatted =
        NumberFormat.currency(locale: formatDevise, symbol: '')
            .format(prix.end);
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
                icon: FaIcon(
                  FontAwesomeIcons.trash,
                  size: 20,
                  color: Colors.black,
                ),
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
                    thickness: 0.1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorie Produit'.tr,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Text(
                          '10.000 MGA a 50.000 MGA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey.shade500,
                    thickness: 0.2,
                  ),
                  Text(
                    'Audience cible'.tr,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                  Text(
                    'Monetaire'.tr,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: Colors.grey.shade500,
                    thickness: 0.2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prix'.tr,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "$PrixDebutformatted - $PrixFinformatted $_currentCurrency",
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
                              min: _minLimit,
                              max: _maxLimit,
                              activeColor: kPrimaryColor,
                              values: prix,
                              onChanged: (value) {
                                setState(() {
                                  prix = value;
                                });
                              }),
                        ],
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Devis Appliquer : $_currentCurrency".tr,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextButton(
                    onPressed: () => _showCurrencyDialog(context, ref),
                    child: Text(
                      'Changer Devis'.tr,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                    ),
                  )
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
            ref.read(mapsUserStateNotifier.notifier).SetUpdateFieldToFilter(
                nationaliteGroupSansFlag: nationaliteGroupSansFlag,
                nationaliteGroup: nationaliteGroup,
                sexe: categorie,
                flag: flag,
                nationalite: nationalite,
                pays: pays,
                rangeOfageDebutAndFin: prix);
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

  // 💰 Fonction pour afficher l'AlertDialog de sélection de devise
  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Devises",
              style: TextStyle(fontWeight: FontWeight.bold)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _currencyTile(context, ref, "EUR", "Euro", Icons.euro),
              _currencyTile(
                  context, ref, "USD", "Dollar US", Icons.attach_money),
              _currencyTile(context, ref, "MGA", "Ariary", Icons.money),
            ],
          ),
        );
      },
    );
  }

  // 🏦 Widget pour afficher chaque devise dans l'AlertDialog
  Widget _currencyTile(BuildContext context, WidgetRef ref, String code,
      String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      trailing: Text(code,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      onTap: () {
        _changeCurrency(code);
      },
    );
  }
}
