import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

class EditerAnnonceMarket extends ConsumerStatefulWidget {
  final String description;
  final String categorie;
  final String price;
  final String title;
  final List<String> photoUrl;
  final String adresse;
  final GeoPoint emplacement;
  final String currency;
  final bool status;
  EditerAnnonceMarket(
      {required this.description,
      required this.categorie,
      required this.price,
      required this.title,
      required this.photoUrl,
      required this.adresse,
      required this.emplacement,
      required this.currency,
      required this.status,
      super.key});

  @override
  ConsumerState<EditerAnnonceMarket> createState() =>
      _EditerAnnonceMarketState();
}

class _EditerAnnonceMarketState extends ConsumerState<EditerAnnonceMarket> {
  final _formKey = GlobalKey<FormState>();
  List<File> selectedFiles = []; // Liste pour stocker les fichiers sélectionnés
  List<String> imageProduit =
      []; // Liste pour stocker les fichiers sélectionnés
  late String lieu = "Ajouter lieux";
  late bool _statusDisponible;
  late double latitude = 0.0;
  late double longitude = 0.0;
  late String _currentCurrency = "";
  late TextEditingController categorieProduit;
  late TextEditingController titreProduit;
  late TextEditingController prixProduit;
  late TextEditingController descriptionProduit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categorieProduit = TextEditingController(
        text: widget.categorie ?? "Selectionnez Categorie");
    titreProduit = TextEditingController(text: widget.title ?? "");
    prixProduit = TextEditingController(text: widget.price ?? "");
    descriptionProduit = TextEditingController(text: widget.description ?? "");
    lieu = widget.adresse.isNotEmpty ? widget.adresse : "Ajouter lieux";
    latitude = widget.emplacement.latitude;
    longitude = widget.emplacement.longitude;
    _currentCurrency = widget.currency;
    imageProduit = widget.photoUrl;
    _statusDisponible = widget.status;
  }

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

  void _showLieuxDialog(BuildContext context) async {
    final selectedLieux = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrouverParLieux(),
      ),
    );

    if (selectedLieux != null) {
      print('le lieux est $selectedLieux');
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
        ref.read(infoUserStateNotifier.notifier).publierVente(
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
        showCustomSnackBar("Choissisez un categorie produit");
      } else if (selectedFiles.isEmpty) {
        showCustomSnackBar("Inserer un image pour le produit");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Permet d'éviter les débordements
        appBar: AppBar(
          title: Text("Publier une annonce".tr,
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
                      controller: descriptionProduit,
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
                        hintText: "Partagez des détails sur ce produit...",
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Détails annonce',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: titreProduit,
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "rempli_champs".tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      titreProduit.text = value.toString();
                    },
                    decoration: InputDecoration(
                      labelText: "Que vendez vous".tr,
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
                      labelText: "Categorie".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: prixProduit,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if ((value == null || value.isEmpty)) {
                        return "rempli_champs".tr;
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
                      'Changer Devis'.tr,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Localisation',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  GestureDetector(
                      onTap: () => _showLieuxDialog(context),
                      child: buildOption(Icon(Icons.location_on), lieu)),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _statusDisponible = !_statusDisponible;
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          activeColor: kPrimaryColor,
                          checkColor: Colors.white,
                          value: _statusDisponible,
                          onChanged: (bool? value) async {
                            setState(() {
                              _statusDisponible = value ?? false;
                            });
                          },
                        ),
                        Text(
                          "Disponible à la vente",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Media', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      child: buildOption(Icon(Icons.add), "Ajouter Photos")),
                  SizedBox(height: 10),
                  Container(
                    height: 55,
                    width: double.infinity,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: imageProduit.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        String file = imageProduit[index]; // Fichier à afficher
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 50,
                                  width: 50,
                                  imageUrl: file,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade100,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                              Positioned(
                                top: 3,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imageProduit
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
                          ),
                        );
                      },
                    ),
                  ),
                  if (imageProduit.isNotEmpty) Divider(),
                  if (imageProduit.isNotEmpty) SizedBox(height: 3),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 5),
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
              Text(text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
