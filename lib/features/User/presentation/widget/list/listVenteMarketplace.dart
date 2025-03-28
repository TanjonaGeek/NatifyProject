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
import 'package:natify/features/User/presentation/widget/postMarketplace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MarketplacePage extends ConsumerWidget {
  MarketplacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String a = "à".tr;
    final notifier = ref.watch(marketPlaceUserStateNotifier);
    var requeteId = const Uuid().v1();
    final Map<String, String> _exchangeFormat = {
      'EUR': 'fr_FR',
      'USD': 'en_US',
      'MGA': 'mg_MG',
    };
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
                              child: Text(
                                "${PrixDebutformatted} $a ${PrixFinformatted} ${notifier.currency}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor),
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
                                child: Text(
                                  'Rayon ${(notifier.radius / 1000).toInt()} Km',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor),
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
            double montant = (data['prix'] is int)
                ? data['prix'].toDouble()
                : double.tryParse(data['prix'].toString()) ?? 0.0;
            String formatDevise = _exchangeFormat[data['currency']] ?? "en_US";
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

// MarketplacePost(
//                   sellerName: data['organizerName'],
//                   sellerProfileImage: data['organizerPhoto'],
//                   postTitle: data['title'],
//                   description: data['description'],
//                   categorie: data['categorie'],
//                   imageUrls: data['images'],
//                   prix: data['prix'],
//                 ),

// GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2, // 2 images par ligne
//                   crossAxisSpacing: 4,
//                   mainAxisSpacing: 4,
//                 ),
//                 itemCount: imageUrls.length > maxImages
//                     ? maxImages + 1
//                     : imageUrls.length,
//                 itemBuilder: (context, index) {
//                   bool isLast = index == 3 && imageUrls.length > 4;
//                   if (index == maxImages && imageUrls.length > maxImages) {
//                     // Si plus d'images que maxImages, afficher "+X"
//                     int remaining = imageUrls.length - maxImages;
//                     return Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: CachedNetworkImage(
//                             imageUrl: imageUrls[maxImages],
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => const Center(
//                                 child: CircularProgressIndicator()),
//                             errorWidget: (context, url, error) =>
//                                 const Icon(Icons.error),
//                           ),
//                         ),
//                         Container(
//                           color: Colors.black54,
//                           alignment: Alignment.center,
//                           child: Text(
//                             "+$remaining",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: CachedNetworkImage(
//                       imageUrl: imageUrls[index],
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) =>
//                           const Center(child: CircularProgressIndicator()),
//                       errorWidget: (context, url, error) =>
//                           const Icon(Icons.error),
//                     ),
//                   );
//                 },
//               ),
