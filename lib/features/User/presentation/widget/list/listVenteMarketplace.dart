import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/detailMarket.dart';
import 'package:natify/features/User/presentation/widget/list/ProductCard.dart';
import 'package:natify/features/User/presentation/widget/list/SearchProduct.dart';
import 'package:natify/features/User/presentation/widget/list/listProductByfiltre.dart';
import 'package:natify/features/User/presentation/widget/list/mapsMarketPlace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  String a = "à".tr;
  String toutCat = "ToutCat".tr;
  final ValueNotifier<List<String>> selectedSubcategories = ValueNotifier([]);
  String? uidMe = FirebaseAuth.instance.currentUser!.uid ?? "";
  List<Map<String, dynamic>> categoriesVente = Helpers.categoriesVente;
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  String rayon = "rayon".tr;

  @override
  void dispose() {
    // TODO: implement dispose
    selectedSubcategories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(marketPlaceUserStateNotifier);
    var requeteId = const Uuid().v1();
    Query query = FirebaseFirestore.instance.collection('marketplace');
    if (notifier.currency.isNotEmpty) {
      query = query.where('currency', isEqualTo: notifier.currency);
    }
    if (notifier.Categorie.isNotEmpty) {
      query = query.where('categorie', isEqualTo: notifier.Categorie);
    }
    if (notifier.isFilterLocation == true) {
      query = query
          .where('latitude', isGreaterThanOrEqualTo: notifier.minlatitude)
          .where('latitude', isLessThanOrEqualTo: notifier.maxlatitude)
          .where('longitude', isGreaterThanOrEqualTo: notifier.minlongitude)
          .where('longitude', isLessThanOrEqualTo: notifier.maxlongitude);
    }
    query = query
        .where('status', isEqualTo: true)
        .where('organizerUid', isNotEqualTo: uidMe)
        .orderBy('prix') // Ordre par âge
        .startAt([notifier.prixProduit.start.toInt()]).endAt(
            [notifier.prixProduit.end.toInt()]);
    String formatDevise = _exchangeFormat[notifier.currency] ?? "en_US";
    String PrixDebutformatted =
        NumberFormat.currency(locale: formatDevise, symbol: '')
            .format(notifier.prixProduit.start);
    String PrixFinformatted =
        NumberFormat.currency(locale: formatDevise, symbol: '')
            .format(notifier.prixProduit.end);
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
          child: SizedBox(
            height: 45,
            child: TextField(
              readOnly: true,
              onTap: () {
                SlideNavigation.slideToPage(context, SearchProduct());
              },
              decoration: InputDecoration(
                hintText: notifier.adressMaps.isNotEmpty
                    ? "${notifier.adressMaps}"
                    : "Rechercher".tr,
                hintStyle: TextStyle(color: Colors.grey),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 1),
                  child: InkWell(
                    onTap: () async {
                      Position positionNews = Position(
                        latitude: notifier.latitude,
                        longitude: notifier.longitude,
                        accuracy:
                            0.0, // Précision, vous pouvez ajuster cette valeur
                        altitude: 0.0, // Altitude par défaut
                        heading: 0.0, // Direction par défaut
                        speed: 0.0, // Vitesse par défaut
                        speedAccuracy: 0.0, // Précision de la vitesse
                        timestamp: DateTime.now(),
                        altitudeAccuracy:
                            0.0, // Ajoutez l'altitudeAccuracy par défaut
                        headingAccuracy: 0.0,
                      );
                      final selectedLieux = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapsMarketPlace(
                              lieuAdress: notifier.adressMaps,
                              currentPosition: positionNews!,
                              rayon: notifier.radius),
                        ),
                      );
                      if (selectedLieux != null) {
                        var lat = double.parse(
                            selectedLieux[0]['latitude'].toString());
                        var lon = double.parse(
                            selectedLieux[0]['longitude'].toString());
                        var rad =
                            double.parse(selectedLieux[0]['radius'].toString());
                        String adress = selectedLieux[0]['lieu'];
                        if (mounted) {
                          if (lat == 0.0 && lon == 0.0) {
                            ref
                                .read(marketPlaceUserStateNotifier.notifier)
                                .SetLocation("", 0.0, 0.0, 10000.0, false);
                          } else {
                            ref
                                .read(marketPlaceUserStateNotifier.notifier)
                                .SetLocation(adress, lon, lat, rad, true);
                          }
                        }
                      }
                    },
                    child: Icon(Icons.place, color: kPrimaryColor),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80, // Hauteur ajustée pour correspondre au design compact
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 10, right: 10),
            itemCount: categoriesVente.length,
            itemBuilder: (context, index) {
              final category = categoriesVente[index];
              final subCategorie = category['subcategories'];
              final titleCategorie = category['title'];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    // if (mounted) {
                    //   ref
                    //       .read(marketPlaceUserStateNotifier.notifier)
                    //       .SetTitleCategorie(titleCategorie);
                    // }
                    int index = categoriesVente.indexWhere(
                      (element) => element["title"] == titleCategorie,
                    );

                    // Vérification pour éviter les erreurs
                    final Map<String, dynamic>? category =
                        (index != -1) ? categoriesVente[index] : null;

                    // 🔥 Assurez-vous que `subcategories` est bien une liste de `String`
                    final List<String> subCategorie =
                        List<String>.from(category?['subcategories'] ?? []);

                    // Afficher le Modal avec les sous-catégories
                    showCustomModal(context, subCategorie, titleCategorie,
                        notifier.Categorie, ref);
                  },
                  child: CategoryCard(
                    category: category,
                  ),
                ),
              );
            },
          ),
        ),
        if (notifier.titreCategorie.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "${notifier.titreCategorie}".tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: FirestorePagination(
            padding: EdgeInsets.zero,
            key: ValueKey(requeteId),
            limit: 15, // Defaults to 10.
            isLive: false, // Defaults to false.s
            viewType: ViewType.grid,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 0.8,
            ),
            bottomLoader: SizedBox(),
            initialLoader: // Section de post
                Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )),
                  ),
                ],
              ),
            ),
            query: query,
            itemBuilder: (context, documentSnapshot, index) {
              final data = documentSnapshot.data() as Map<String, dynamic>?;
              if (data == null) {
                return Container();
              }
              double montant = (data['prix'] is int)
                  ? data['prix'].toDouble()
                  : double.tryParse(data['prix'].toString()) ?? 0.0;
              String formatDevise =
                  _exchangeFormat[data['currency']] ?? "en_US";
              String prix =
                  NumberFormat.currency(locale: formatDevise, symbol: '')
                      .format(montant);
              return InkWell(
                  onTap: () {
                    SlideNavigation.slideToPage(
                      context,
                      ProductDetailScreen(
                          categ: data['categorie'],
                          productId: data['uidVente'],
                          emplacement: data['location']['geopoint']),
                    );
                  },
                  child: ProductCard(
                      imageUrl: data['images'][0],
                      title: data['title'],
                      price: prix,
                      currency: data['currency'],
                      emplacement: data['location']['geopoint']));
            },
            onEmpty: Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.asset(
                        'assets/marketplace (1).png',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      textAlign: TextAlign.center,
                      "Aucun_produit_disponible.".tr,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    // SizedBox(height: 4),
                    // Text(
                    //   textAlign: TextAlign.center,
                    //   "Actuellement_aucun_produit".tr,
                    //   style:
                    //       TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }
}

void showCustomModal(BuildContext context, List<String> subCategorie,
    String titre, String cat, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Pour ajuster selon le contenu
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        width: double.infinity, // Pleine largeur
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "${titre}".tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Wrap(
                  alignment: WrapAlignment.start, // Aligner à gauche
                  crossAxisAlignment:
                      WrapCrossAlignment.start, // Alignement vertical en haut
                  runAlignment:
                      WrapAlignment.start, // Aligner les lignes à gauche
                  spacing: 5,
                  runSpacing: 7,
                  children: subCategorie.map<Widget>((sub) {
                    // ✅ Ajout du type <Widget>
                    return InkWell(
                      onTap: () {
                        ref
                            .read(marketPlaceUserStateNotifier.notifier)
                            .SetTitleCategorieAndCategorie(titre, sub);
                        Navigator.pop(context);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                  color: Colors.blue.shade50,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              child: Text(sub.tr),
                            ),
                          ),
                          if (cat == sub)
                            Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(marketPlaceUserStateNotifier
                                            .notifier)
                                        .SetTitleCategorieAndCategorie("", "");
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Center(
                                      child: FaIcon(FontAwesomeIcons.close,
                                          color: Colors.white, size: 13),
                                    ),
                                  ),
                                ))
                        ],
                      ),
                    );
                  }).toList(), // ✅ Convertir en List<Widget>
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65, // Largeur ajustée pour être plus petite
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category["icon"],
              size: 20, color: kPrimaryColor), // Taille réduite
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              "${category["title"]}".tr,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12), // Taille de police réduite
            ),
          ),
        ],
      ),
    );
  }
}
