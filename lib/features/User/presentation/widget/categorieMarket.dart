import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/colors.dart';

class CategoriesDialog extends StatelessWidget {
  final List<Map<String, dynamic>> categoriesVente = [
    {
      "title": "Immobilier & Hébergement",
      "icon": Icons.home,
      "subcategories": [
        "Vente immobilière",
        "Location immobilière",
        "Colocation & Sous-location",
        "Bureaux & Espaces de travail",
      ],
    },
    {
      "title": "Véhicules & Mobilité",
      "icon": Icons.directions_car,
      "subcategories": [
        "Voitures & 4x4",
        "Motos & Scooters",
        "Vélos & Trottinettes électriques",
        "Camions & Utilitaires",
        "Bateaux & Jet-skis",
        "Pièces & Accessoires auto/moto",
        "Services automobiles",
      ],
    },
    {
      "title": "Informatique, High-Tech & Jeux",
      "icon": Icons.computer,
      "subcategories": [
        "Ordinateurs & Accessoires",
        "Téléphones & Tablettes",
        "Consoles & Jeux vidéo",
        "TV, Audio & Vidéo",
        "Objets connectés & Gadgets",
      ],
    },
    {
      "title": "Maison, Meubles & Décoration",
      "icon": Icons.weekend,
      "subcategories": [
        "Meubles & Rangement",
        "Électroménager",
        "Décoration & Arts de la table",
        "Jardin & Bricolage",
      ],
    },
    {
      "title": "Mode & Accessoires",
      "icon": Icons.shopping_bag,
      "subcategories": [
        "Vêtements Hommes & Femmes",
        "Vêtements Hommes",
        "Vêtements Femmes",
        "Vêtements Enfants & Bébés",
        "Chaussures & Sneakers",
        "Montres & Bijoux",
        "Sacs & Accessoires de mode",
        "Lunettes de soleil & Optique",
      ],
    },
    {
      "title": "Loisirs, Sports & Divertissement",
      "icon": Icons.sports_soccer,
      "subcategories": [
        "Équipements sportifs",
        "Musique & Instruments",
        "Jouets & Jeux de société",
        "Camping & Plein air",
      ],
    },
    {
      "title": "Éducation & Fournitures scolaires",
      "icon": Icons.menu_book,
      "subcategories": [
        "Livres & Manuels scolaires",
        "Fournitures de bureau",
        "Équipements scolaires",
      ],
    },
    {
      "title": "Autres catégories",
      "icon": Icons.category,
      "subcategories": [
        "Produits alimentaires & Bio",
        "Animaux & Accessoires",
        "Santé & Bien-être",
        "Équipements professionnels",
        "Antiquités & Objets de collection",
        "Articles de fête & Cadeaux",
      ],
    },
  ];

  CategoriesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Choix_catégorie".tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categoriesVente.length,
          itemBuilder: (context, index) {
            final category = categoriesVente[index];
            return ExpansionTile(
              leading: Icon(category["icon"], color: kPrimaryColor),
              title: Text("${category["title"]}".tr,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: (category["subcategories"] as List<String>)
                  .map((sub) => ListTile(
                        title: Text("${sub}".tr),
                        onTap: () {
                          Navigator.pop(context,
                              sub); // Retourne la sous-catégorie sélectionnée
                        },
                      ))
                  .toList(),
            );
          },
        ),
      ),
      // actions: [
      //   TextButton(
      //     onPressed: () => Navigator.pop(context),
      //     child: Text("Fermer"),
      //   ),
      // ],
    );
  }
}
