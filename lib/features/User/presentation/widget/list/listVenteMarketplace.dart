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
import 'package:natify/features/User/presentation/widget/list/SearchProduct.dart';
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
  String? uidMe = FirebaseAuth.instance.currentUser!.uid ?? "";
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  final List<Category> categories = [
    Category(icon: Icons.home, label: 'Immobilier & Hébergement'),
    Category(icon: Icons.directions_car, label: 'Véhicules & Mobilité'),
    Category(icon: Icons.computer, label: 'Informatique, High-Tech & Jeux'),
    Category(icon: Icons.weekend, label: 'Maison, Meubles & Décoration'),
    Category(icon: Icons.category, label: 'Autres catégories'),
  ];
  String rayon = "rayon".tr;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(marketPlaceUserStateNotifier);
    var requeteId = const Uuid().v1();
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
        // Container(
        //   padding: EdgeInsets.all(8.0),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Flexible(
        //         child: SingleChildScrollView(
        //           scrollDirection: Axis.horizontal,
        //           child: Row(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               if (notifier.nameSearch.isNotEmpty)
        //                 Container(
        //                     decoration: BoxDecoration(
        //                         border: Border.all(color: kPrimaryColor),
        //                         borderRadius:
        //                             BorderRadius.all(Radius.circular(20))),
        //                     child: Padding(
        //                       padding: const EdgeInsets.symmetric(
        //                           horizontal: 10, vertical: 10),
        //                       child: Row(
        //                         children: [
        //                           Text(
        //                             "Mots-cle".tr,
        //                             style: TextStyle(
        //                                 fontWeight: FontWeight.bold,
        //                                 color: kPrimaryColor),
        //                           ),
        //                           SizedBox(
        //                             width: 7,
        //                           ),
        //                           Text(
        //                             "${notifier.nameSearch}",
        //                             style: TextStyle(
        //                                 fontWeight: FontWeight.bold,
        //                                 color: kPrimaryColor),
        //                           ),
        //                           SizedBox(
        //                             width: 7,
        //                           ),
        //                           GestureDetector(
        //                             onTap: () {
        //                               ref
        //                                   .read(marketPlaceUserStateNotifier
        //                                       .notifier)
        //                                   .ClearFilterTerm();
        //                             },
        //                             child: FaIcon(FontAwesomeIcons.close,
        //                                 color: Colors.black.withOpacity(0.6),
        //                                 size: 16),
        //                           )
        //                         ],
        //                       ),
        //                     )),
        //               if (notifier.nameSearch.isNotEmpty)
        //                 SizedBox(
        //                   width: 5,
        //                 ),
        //               Container(
        //                   decoration: BoxDecoration(
        //                       border: Border.all(color: kPrimaryColor),
        //                       borderRadius:
        //                           BorderRadius.all(Radius.circular(20))),
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(
        //                         horizontal: 10, vertical: 10),
        //                     child: Row(
        //                       children: [
        //                         FaIcon(FontAwesomeIcons.boxOpen,
        //                             color: kPrimaryColor, size: 14),
        //                         SizedBox(
        //                           width: 5,
        //                         ),
        //                         Text(
        //                           notifier.Categorie.isNotEmpty
        //                               ? '${notifier.Categorie}'.tr
        //                               : 'ToutCat'.tr,
        //                           style: TextStyle(
        //                               fontWeight: FontWeight.bold,
        //                               color: kPrimaryColor),
        //                         ),
        //                         if (notifier.Categorie.isNotEmpty)
        //                           SizedBox(
        //                             width: 7,
        //                           ),
        //                         // ref.watch(marketPlaceUserStateNotifier)
        //                         if (notifier.Categorie.isNotEmpty)
        //                           GestureDetector(
        //                             onTap: () {
        //                               ref
        //                                   .read(marketPlaceUserStateNotifier
        //                                       .notifier)
        //                                   .ClearFilterCategorie();
        //                             },
        //                             child: FaIcon(FontAwesomeIcons.close,
        //                                 color: Colors.black.withOpacity(0.6),
        //                                 size: 16),
        //                           )
        //                       ],
        //                     ),
        //                   )),
        //               SizedBox(
        //                 width: 5,
        //               ),
        //               Container(
        //                   decoration: BoxDecoration(
        //                       border: Border.all(color: kPrimaryColor),
        //                       borderRadius:
        //                           BorderRadius.all(Radius.circular(20))),
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(
        //                         horizontal: 10, vertical: 10),
        //                     child: Row(
        //                       children: [
        //                         Text(
        //                           "${PrixDebutformatted} $a ${PrixFinformatted} ${notifier.currency}",
        //                           style: TextStyle(
        //                               fontWeight: FontWeight.bold,
        //                               color: kPrimaryColor),
        //                         ),
        //                         (notifier.prixProduit ==
        //                                     RangeValues(5000.0, 50000000.0) ||
        //                                 notifier.prixProduit ==
        //                                     RangeValues(1.0, 10000.0))
        //                             ? SizedBox.shrink()
        //                             : SizedBox(
        //                                 width: 7,
        //                               ),
        //                         (notifier.prixProduit ==
        //                                     RangeValues(5000.0, 50000000.0) ||
        //                                 notifier.prixProduit ==
        //                                     RangeValues(1.0, 10000.0))
        //                             ? SizedBox.shrink()
        //                             : GestureDetector(
        //                                 onTap: () {
        //                                   ref
        //                                       .read(marketPlaceUserStateNotifier
        //                                           .notifier)
        //                                       .ClearFilterPrix();
        //                                 },
        //                                 child: FaIcon(FontAwesomeIcons.close,
        //                                     color:
        //                                         Colors.black.withOpacity(0.6),
        //                                     size: 16),
        //                               )
        //                       ],
        //                     ),
        //                   )),
        //               SizedBox(
        //                 width: 5,
        //               ),
        //               if (notifier.isFilterLocation == true)
        //                 Container(
        //                     decoration: BoxDecoration(
        //                         border: Border.all(color: kPrimaryColor),
        //                         borderRadius:
        //                             BorderRadius.all(Radius.circular(20))),
        //                     child: Padding(
        //                       padding: const EdgeInsets.symmetric(
        //                           horizontal: 10, vertical: 10),
        //                       child: Row(
        //                         children: [
        //                           FaIcon(FontAwesomeIcons.locationDot,
        //                               color: kPrimaryColor, size: 14),
        //                           SizedBox(
        //                             width: 5,
        //                           ),
        //                           Text(
        //                             "${notifier.adressMaps}",
        //                             style: TextStyle(
        //                                 fontWeight: FontWeight.bold,
        //                                 color: kPrimaryColor),
        //                           ),
        //                           if (notifier.adressMaps.isNotEmpty)
        //                             SizedBox(
        //                               width: 7,
        //                             ),
        //                           if (notifier.adressMaps.isNotEmpty)
        //                             GestureDetector(
        //                               onTap: () {
        //                                 ref
        //                                     .read(marketPlaceUserStateNotifier
        //                                         .notifier)
        //                                     .ClearFilterAdresse();
        //                               },
        //                               child: FaIcon(FontAwesomeIcons.close,
        //                                   color: Colors.black.withOpacity(0.6),
        //                                   size: 16),
        //                             )
        //                         ],
        //                       ),
        //                     )),
        //               SizedBox(
        //                 width: 5,
        //               ),
        //               if (notifier.isFilterLocation == true)
        //                 Container(
        //                     decoration: BoxDecoration(
        //                         border: Border.all(color: kPrimaryColor),
        //                         borderRadius:
        //                             BorderRadius.all(Radius.circular(20))),
        //                     child: Padding(
        //                       padding: const EdgeInsets.symmetric(
        //                           horizontal: 10, vertical: 10),
        //                       child: Row(
        //                         children: [
        //                           Text(
        //                             '${rayon} ${(notifier.radius / 1000).toInt()} Km',
        //                             style: TextStyle(
        //                                 fontWeight: FontWeight.bold,
        //                                 color: kPrimaryColor),
        //                           ),
        //                           if (notifier.radius > 10000.0)
        //                             SizedBox(
        //                               width: 7,
        //                             ),
        //                           if (notifier.radius > 10000.0)
        //                             GestureDetector(
        //                               onTap: () {
        //                                 ref
        //                                     .read(marketPlaceUserStateNotifier
        //                                         .notifier)
        //                                     .ClearFilterRayon();
        //                               },
        //                               child: FaIcon(FontAwesomeIcons.close,
        //                                   color: Colors.black.withOpacity(0.6),
        //                                   size: 16),
        //                             )
        //                         ],
        //                       ),
        //                     )),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            readOnly: true,
            onTap: () {
              SlideNavigation.slideToPage(context, SearchProduct());
            },
            decoration: InputDecoration(
              hintText: notifier.adressMaps.isNotEmpty
                  ? notifier.adressMaps
                  : "Rechercher".tr,
              hintStyle: TextStyle(color: Colors.grey),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 1),
                child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    ),
                    child: Icon(Icons.place, color: kPrimaryColor)),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80, // Hauteur ajustée pour correspondre au design compact
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 30, right: 30),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CategoryCard(category: categories[index]),
              );
            },
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
