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
  final ValueNotifier<String> selectedcategories = ValueNotifier("");
  String? uidMe = FirebaseAuth.instance.currentUser!.uid ?? "";
  List<Map<String, dynamic>> categoriesVente = Helpers.categoriesVente;
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  String rayon = "rayon".tr;

  void updateSubcategories(List<String> subcategories, String titleCategorie) {
    selectedSubcategories.value =
        subcategories; // Met à jour les sous-catégories
    selectedcategories.value = titleCategorie;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectedSubcategories.dispose();
    selectedcategories.dispose();
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
                            print('le etape 1');
                            ref
                                .read(marketPlaceUserStateNotifier.notifier)
                                .SetLocation("", 0.0, 0.0, 10000.0, false);
                          } else {
                            print('le etape 2');
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
                    updateSubcategories(subCategorie, titleCategorie);
                    // if (mounted) {
                    //   ref
                    //       .read(marketPlaceUserStateNotifier.notifier)
                    //       .SetCategorie(category['title']);
                    // }
                    // SlideNavigation.slideToPage(
                    //     context,
                    //     MarketplaceResultFiltrePage(
                    //       nameTerm: "",
                    //     ));
                  },
                  child: CategoryCard(
                    category: category,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 5,
        ),

        /// Affichage des sous-catégories avec `Wrap`
        ValueListenableBuilder<List<String>>(
          valueListenable: selectedSubcategories,
          builder: (context, subcategories, _) {
            return subcategories.isEmpty
                ? SizedBox()
                : Theme(
                    data: ThemeData().copyWith(
                      dividerColor:
                          Colors.transparent, // Supprime la ligne de séparation
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text("${selectedcategories.value}".tr,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Wrap(
                              alignment:
                                  WrapAlignment.start, // Aligner à gauche
                              crossAxisAlignment: WrapCrossAlignment
                                  .start, // Alignement vertical en haut
                              runAlignment: WrapAlignment
                                  .start, // Aligner les lignes à gauche
                              spacing: 5,
                              runSpacing: 7,
                              children: subcategories.map((sub) {
                                return InkWell(
                                  onTap: () {
                                    SlideNavigation.slideToPage(
                                        context,
                                        MarketplaceResultFiltrePage(
                                          nameTerm: "",
                                          categorieSelectionner: sub,
                                        ));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all()),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${sub}'.tr),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
          },
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
              childAspectRatio: 0.7,
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
