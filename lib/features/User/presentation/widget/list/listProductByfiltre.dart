import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/detailMarket.dart';
import 'package:natify/features/User/presentation/widget/list/ProductCard.dart';
import 'package:natify/features/User/presentation/widget/list/SearchProduct.dart';
import 'package:natify/features/User/presentation/widget/list/filterListOfProduct.dart';
import 'package:natify/features/User/presentation/widget/list/mapsMarketPlace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MarketplaceResultFiltrePage extends ConsumerStatefulWidget {
  final String nameTerm;
  final String categorieSelectionner;
  MarketplaceResultFiltrePage(
      {required this.nameTerm, required this.categorieSelectionner, super.key});

  @override
  ConsumerState<MarketplaceResultFiltrePage> createState() =>
      _MarketplaceResultFiltrePageState();
}

class _MarketplaceResultFiltrePageState
    extends ConsumerState<MarketplaceResultFiltrePage> {
  String a = "à".tr;
  String toutCat = "ToutCat".tr;
  String? uidMe = FirebaseAuth.instance.currentUser!.uid ?? "";
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  String rayon = "rayon".tr;
  String term = "";
  bool isUserSubscribed(String uid, List<dynamic> userFavoriedUids) {
    // Convertir la List<dynamic> en Set<String> pour améliorer les performances
    Set<String> userFavoriedUidsSet =
        Set<String>.from(userFavoriedUids.whereType<String>());
    return userFavoriedUidsSet.contains(uid);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    term = widget.nameTerm;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(marketPlaceUserStateNotifier);
    var requeteId = const Uuid().v1();
    Query query = FirebaseFirestore.instance.collection('marketplace');
    // Ajouter les filtres de recherche
    if (term.isNotEmpty) {
      query = query.where('nameProduit', arrayContains: term.toLowerCase());
    }
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
        appBar: AppBar(
          title: SizedBox(
            height: 45,
            child: TextFormField(
              readOnly: true,
              onTap: () {
                SlideNavigation.slideToPage(context, SearchProduct());
              },
              decoration: InputDecoration(
                suffixIcon: term.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            term = "";
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                      )
                    : InkWell(
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
                            var rad = double.parse(
                                selectedLieux[0]['radius'].toString());
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
                        child: Icon(Icons.place, color: kPrimaryColor)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 2.0,
                  ),
                ),
                contentPadding:
                    EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
                hintText: term.isNotEmpty
                    ? "${term}"
                    : notifier.adressMaps.isNotEmpty
                        ? "${notifier.adressMaps}"
                        : "Rechercher".tr,
                hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              onChanged: (query) {
                // Obtenir les suggestions à chaque changement de texte
              },
            ),
          ),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Center(
                  child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                size: 20,
              )),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                SlideNavigation.slideToPage(context, FilterProductPage());
              },
              icon: FaIcon(
                FontAwesomeIcons.sliders,
                size: 22,
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: kPrimaryColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.boxOpen,
                                        color: kPrimaryColor, size: 14),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      notifier.Categorie.isNotEmpty
                                          ? '${notifier.Categorie}'.tr
                                          : 'ToutCat'.tr,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor),
                                    ),
                                    if (notifier.Categorie.isNotEmpty)
                                      SizedBox(
                                        width: 7,
                                      ),
                                    // ref.watch(marketPlaceUserStateNotifier)
                                    if (notifier.Categorie.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(marketPlaceUserStateNotifier
                                                  .notifier)
                                              .SetCategorie("");
                                        },
                                        child: FaIcon(FontAwesomeIcons.close,
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            size: 16),
                                      )
                                  ],
                                ),
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: kPrimaryColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      "${PrixDebutformatted} $a ${PrixFinformatted} ${notifier.currency}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor),
                                    ),
                                    (notifier.prixProduit ==
                                                RangeValues(
                                                    5000.0, 50000000.0) ||
                                            notifier.prixProduit ==
                                                RangeValues(1.0, 10000.0))
                                        ? SizedBox.shrink()
                                        : SizedBox(
                                            width: 7,
                                          ),
                                    (notifier.prixProduit ==
                                                RangeValues(
                                                    5000.0, 50000000.0) ||
                                            notifier.prixProduit ==
                                                RangeValues(1.0, 10000.0))
                                        ? SizedBox.shrink()
                                        : GestureDetector(
                                            onTap: () {
                                              ref
                                                  .read(
                                                      marketPlaceUserStateNotifier
                                                          .notifier)
                                                  .ClearFilterPrix();
                                            },
                                            child: FaIcon(
                                                FontAwesomeIcons.close,
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                size: 16),
                                          )
                                  ],
                                ),
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          if (notifier.isFilterLocation == true)
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: kPrimaryColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    children: [
                                      FaIcon(FontAwesomeIcons.locationDot,
                                          color: kPrimaryColor, size: 14),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${notifier.adressMaps}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor),
                                      ),
                                      if (notifier.adressMaps.isNotEmpty)
                                        SizedBox(
                                          width: 7,
                                        ),
                                      if (notifier.adressMaps.isNotEmpty)
                                        GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(
                                                    marketPlaceUserStateNotifier
                                                        .notifier)
                                                .ClearFilterAdresse();
                                          },
                                          child: FaIcon(FontAwesomeIcons.close,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              size: 16),
                                        )
                                    ],
                                  ),
                                )),
                          SizedBox(
                            width: 5,
                          ),
                          if (notifier.isFilterLocation == true)
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: kPrimaryColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${rayon} ${(notifier.radius / 1000).toInt()} Km',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor),
                                      ),
                                      if (notifier.radius > 10000.0)
                                        SizedBox(
                                          width: 7,
                                        ),
                                      if (notifier.radius > 10000.0)
                                        GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(
                                                    marketPlaceUserStateNotifier
                                                        .notifier)
                                                .ClearFilterRayon();
                                          },
                                          child: FaIcon(FontAwesomeIcons.close,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              size: 16),
                                        )
                                    ],
                                  ),
                                )),
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
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
                  bool isFav = isUserSubscribed(uidMe!, data['favorie'] ?? []);
                  int nbrFav = data['favorie'].length;
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
                            emplacement: data['location']['geopoint'],
                            favorieList: data['favorie'],
                          ),
                        );
                      },
                      child: ProductCard(
                          isFav: isFav,
                          nbrFav: nbrFav,
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
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
  final Category category;
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
          Icon(category.icon, size: 20, color: kPrimaryColor), // Taille réduite
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              "${category.label}".tr,
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

class Category {
  final IconData icon;
  final String label;
  Category({required this.icon, required this.label});
}
