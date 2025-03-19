import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/services.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/widget/nationaliteListPage.dart';
import 'package:natify/features/User/presentation/widget/categorieMarket.dart';
import 'package:natify/features/User/presentation/widget/galleryannoncephoto.dart';
import 'package:natify/features/User/presentation/widget/lieuvente.dart';

class CreateAnnonceMarket extends ConsumerStatefulWidget {
  const CreateAnnonceMarket({super.key});

  @override
  ConsumerState<CreateAnnonceMarket> createState() =>
      _CreateAnnonceMarketState();
}

class _CreateAnnonceMarketState extends ConsumerState<CreateAnnonceMarket> {
  List<File> selectedFiles = []; // Liste pour stocker les fichiers sélectionnés
  String cibleNationalite = "Choisissez nationalite";
  final List<Map<String, String>> listNationalitesAndPays =
      Helpers.ListeNationaliteHelper;
  String ciblePays = "Choisissez pays";
  String lieu = "Ajouter lieux";
  String flag = "";
  final TextEditingController categorieProduit =
      TextEditingController(text: "Selectionnez Categorie");
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

  void _showLieuxDialog(BuildContext context) async {
    final selectedLieux = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrouverParLieux(),
      ),
    );

    if (selectedLieux != null) {
      setState(() {
        lieu = selectedLieux;
      });
    }
  }

  void _showNationaliteDialog(BuildContext context) async {
    final selectedNationalite = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NationaliteListPage(listNationalite: listNationalitesAndPays),
      ),
    );

    if (selectedNationalite != null) {
      setState(() {
        cibleNationalite = selectedNationalite['nationality'] ?? '';
        flag = selectedNationalite['flagCode'] ?? '';
      });
    }
  }

  void _showPaysDialog(BuildContext context) async {
    final selectedPays = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NationaliteListPage(listNationalite: listNationalitesAndPays),
      ),
    );

    if (selectedPays != null) {
      setState(() {
        ciblePays = selectedPays['country'] ?? '';
      });
    }
  }

  Future<void> publierVente() async{

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
              onPressed: () {},
              child: Text(
                "Publier".tr,
                style: TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
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
                  child: TextField(
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
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return "rempli_champs".tr;
                    }
                    return null;
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if ((value == null || value.isEmpty)) {
                      return "rempli_champs".tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Prix".tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
                SizedBox(height: 10),
                Text('Localisation',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                GestureDetector(
                    onTap: () => _showLieuxDialog(context),
                    child: buildOption(Icon(Icons.location_on), "${lieu}")),
                SizedBox(height: 10),
                Text('Audience cible',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () => _showNationaliteDialog(context),
                        child: buildOption(
                            flag.isEmpty ? Icon(Icons.add) : Text('${flag}'),
                            "${cibleNationalite}")),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () => _showPaysDialog(context),
                        child: buildOption(
                            ciblePays == "Choisissez pays"
                                ? Icon(Icons.add)
                                : SizedBox.shrink(),
                            "${ciblePays}")),
                  ],
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
                              image:
                                  FileImage(file), // Affichage du fichier local
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
                // Spacer(),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: () {},
                //     child: Text(
                //       "PUBLIER",
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //     ),
                //   ),
                // ),
              ],
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
