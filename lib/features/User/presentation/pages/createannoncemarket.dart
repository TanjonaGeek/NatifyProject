import 'dart:io';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/services.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/categorieMarket.dart';
import 'package:natify/features/User/presentation/widget/galleryannoncephoto.dart';
import 'package:natify/features/User/presentation/widget/lieuvente.dart';
import 'package:intl/intl.dart';

class CreateAnnonceMarket extends ConsumerStatefulWidget {
  const CreateAnnonceMarket({super.key});

  @override
  ConsumerState<CreateAnnonceMarket> createState() =>
      _CreateAnnonceMarketState();
}

class _CreateAnnonceMarketState extends ConsumerState<CreateAnnonceMarket> {
  final _formKey = GlobalKey<FormState>();
  List<File> selectedFiles = []; // Liste pour stocker les fichiers sélectionnés
  String lieu = "Ajouter_lieux".tr;
  String flag = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String _currentCurrency = "USD";
  String prix_entre = "prix_entre".tr;
  String et = "et".tr;
  int _currentLength = 0; // Compteur pour la longueur du texte
  final int _maxLength = 30; // Limite maximale de caractères
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  final TextEditingController categorieProduit = TextEditingController();
  final TextEditingController titreProduit = TextEditingController();
  final TextEditingController prixProduit = TextEditingController();
  final TextEditingController descriptionProduit = TextEditingController();
  void _showCategoriesDialog(BuildContext context) async {
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) => CategoriesDialog(),
    );

    if (selectedCategory != null) {
      categorieProduit.text = selectedCategory;
    }
  }

  // Fonction pour changer la devise et ajuster les prix
  void _changeCurrency(String newCurrency) {
    setState(() {
      _currentCurrency = newCurrency;
    });
    Navigator.pop(context); // Fermer l'AlertDialog
  }

  // 💰 Fonction pour afficher l'AlertDialog de sélection de devise
  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text("Devises".tr, style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showLieuxDialog(BuildContext context) async {
    final selectedLieux = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrouverParLieux(),
      ),
    );

    if (selectedLieux != null) {
      setState(() {
        lieu = selectedLieux[0]['lieu'];
        latitude = selectedLieux[0]['latitude'];
        longitude = selectedLieux[0]['longitude'];
      });
    }
  }

  Future<void> publierVente() async {
    final notifier = ref.read(infoUserStateNotifier);
    if (categorieProduit.text.isNotEmpty && selectedFiles.isNotEmpty) {
      if (mounted) {
        ref.read(marketPlaceUserStateNotifier.notifier).publierVente(
            notifier.MydataPersiste!,
            titreProduit.text,
            descriptionProduit.text,
            latitude,
            longitude,
            selectedFiles,
            [],
            [],
            int.parse(prixProduit.text),
            categorieProduit.text,
            _currentCurrency,
            titreProduit.text);
      }
      Navigator.pop(context);
    } else {
      if (categorieProduit.text.isEmpty) {
        showCustomSnackBar("Choisissez_catégorie");
      } else if (selectedFiles.isEmpty) {
        showCustomSnackBar("Insérez_produit.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Permet d'éviter les débordements
        appBar: AppBar(
          title: Text("Publier_annonce".tr,
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
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  publierVente();
                }
              },
              child: Text(
                "Publier".tr,
                style: TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if ((value == null || value.isEmpty)) {
                          return "rempli_champs".tr;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        descriptionProduit.text = value.toString();
                      },
                      decoration: InputDecoration(
                        hintText: "Partagez_détails".tr,
                        border: InputBorder.none,
                      ),
                      maxLines:
                          null, // Permet au champ de s'étendre verticalement
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Détails_annonce".tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          _maxLength), // Limite à 10 caractères
                    ],
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "rempli_champs".tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      titreProduit.text = value.toString();
                      setState(() {
                        _currentLength = value.length;
                      });
                    },
                    decoration: InputDecoration(
                      suffix: Text(
                        _currentLength == 0 ? "" : "$_currentLength",
                        style: TextStyle(fontSize: 14),
                      ),
                      labelText: "Que_vendez_vous".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: categorieProduit,
                    onTap: () => _showCategoriesDialog(context),
                    readOnly: true,
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "rempli_champs".tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      categorieProduit.text = value.toString();
                    },
                    decoration: InputDecoration(
                      labelText: "Selectionnez_Categorie".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "rempli_champs".tr;
                      }
                      // Définir les valeurs min et max en fonction de la devise
                      double minPrice = 1;
                      double maxPrice = 10000;

                      if (_currentCurrency == "MGA") {
                        minPrice = 5000;
                        maxPrice = 50000000;
                      }

                      double? price = double.tryParse(value);
                      if (price == null) {
                        return "Valeur_invalide".tr;
                      }

                      if (price < minPrice || price > maxPrice) {
                        String formatDevise =
                            _exchangeFormat[_currentCurrency] ?? "en_US";
                        String prixMin = NumberFormat.currency(
                                locale: formatDevise, symbol: '')
                            .format(minPrice);
                        String prixMax = NumberFormat.currency(
                                locale: formatDevise, symbol: '')
                            .format(maxPrice);
                        return "${prix_entre} $prixMin ${et} $prixMax $_currentCurrency";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      prixProduit.text = value.toString();
                    },
                    decoration: InputDecoration(
                      suffix: Text(
                        _currentCurrency,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      labelText: "Prix".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showCurrencyDialog(context, ref),
                    child: Text(
                      'Changer_Devis'.tr,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Emplacement'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GestureDetector(
                      onTap: () => _showLieuxDialog(context),
                      child: buildOption(Icon(Icons.location_on), lieu)),
                  SizedBox(height: 10),
                  Text('Visuels_produit'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GestureDetector(
                      onTap: () async {
                        final selectedPhoto = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryAnnoncePhoto(),
                          ),
                        );
                        if (selectedPhoto != null) {
                          setState(() {
                            selectedFiles = selectedPhoto;
                          });
                        }
                        // SlideNavigation.slideToPage(context, GalleryAnnoncePhoto());
                      },
                      child: buildOption(
                          Icon(Icons.photo_camera), "Ajouter_Photos".tr)),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Nombre de colonnes
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1, // Ajuster selon le besoin
                    ),
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = selectedFiles[index]; // Fichier à afficher

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(
                                    file), // Affichage du fichier local
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 3,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFiles
                                      .removeAt(index); // Supprime l'image
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOption(Widget icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              icon,
              SizedBox(width: 10),
              Flexible(
                child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
