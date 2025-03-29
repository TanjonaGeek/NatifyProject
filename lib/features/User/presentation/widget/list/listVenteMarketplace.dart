import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/detailMarket.dart';
import 'package:natify/features/User/presentation/widget/list/ProductCard.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class MarketplacePage extends ConsumerWidget {
  MarketplacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String a = "à".tr;
    String? uidMe = FirebaseAuth.instance.currentUser!.uid ?? "";
    final notifier = ref.watch(marketPlaceUserStateNotifier);
    var requeteId = const Uuid().v1();
    final Map<String, String> _exchangeFormat = {
      'EUR': 'fr_FR',
      'USD': 'en_US',
      'MGA': 'mg_MG',
    };

    double calculateDistance(GeoPoint point1, GeoPoint point2) {
      return Geolocator.distanceBetween(
            point1.latitude,
            point1.longitude,
            point2.latitude,
            point2.longitude,
          ) /
          1000; // Convertir en kilomètres
    }

    Query query = FirebaseFirestore.instance.collection('marketplace');
    // Ajouter les filtres de recherche
    if (notifier.nameSearch.isNotEmpty) {
      query = query.where('nameProduit',
          arrayContains: notifier.nameSearch.toLowerCase());
    }
    if (notifier.currency.isNotEmpty) {
      query = query.where('currency', isEqualTo: notifier.currency);
    }
    if (notifier.Categorie.isNotEmpty) {
      query = query.where('categorie', isEqualTo: notifier.Categorie);
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
          padding: const EdgeInsets.all(8.0),
          child: Container(
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
                                        ? '${notifier.Categorie}'
                                        : 'Toute Categories',
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
                                            .ClearFilterCategorie();
                                      },
                                      child: FaIcon(FontAwesomeIcons.close,
                                          color: Colors.black.withOpacity(0.6),
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
                                              RangeValues(5000.0, 50000000.0) ||
                                          notifier.prixProduit ==
                                              RangeValues(1.0, 10000.0))
                                      ? SizedBox.shrink()
                                      : SizedBox(
                                          width: 7,
                                        ),
                                  (notifier.prixProduit ==
                                              RangeValues(5000.0, 50000000.0) ||
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
                                              .read(marketPlaceUserStateNotifier
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
                                      'Rayon ${(notifier.radius / 1000).toInt()} Km',
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
                                              .read(marketPlaceUserStateNotifier
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
        ),
        FirestorePagination(
          key: ValueKey(requeteId),
          shrinkWrap: true,
          limit: 15, // Defaults to 10.
          isLive: false, // Defaults to false.s
          viewType: ViewType.grid,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          bottomLoader: SizedBox(),
          initialLoader: // Section de post
              SizedBox(),
          query: query,
          itemBuilder: (context, documentSnapshot, index) {
            final data = documentSnapshot.data() as Map<String, dynamic>?;
            if (data == null) {
              return Container();
            }
            GeoPoint geoPointCible = data['location']['geopoint'];
            GeoPoint geoPointfiltre =
                GeoPoint(notifier.latitude, notifier.longitude);
            double montant = (data['prix'] is int)
                ? data['prix'].toDouble()
                : double.tryParse(data['prix'].toString()) ?? 0.0;
            String formatDevise = _exchangeFormat[data['currency']] ?? "en_US";
            String prix =
                NumberFormat.currency(locale: formatDevise, symbol: '')
                    .format(montant);
            if (notifier.isFilterLocation == true) {
              // Calculer la distance entre l'utilisateur et le point récupéré
              double distance = calculateDistance(
                geoPointfiltre,
                geoPointCible,
              );
              // Si la distance est supérieure au rayon, cacher cet élément
              // Si la distance est supérieure au rayon (en mètres ou en kilomètres)
              if (distance > notifier.radius / 1000) {
                // Si rayon en mètres, diviser par 1000
                return SizedBox.shrink();
              }
            }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  "Aucun produit disponible".tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 4),
                Text(
                  textAlign: TextAlign.center,
                  "Actuellement, aucun produit n'est en vente sur Marketplace"
                      .tr,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
