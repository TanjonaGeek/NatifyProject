import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/createannoncemarket.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/detailMarketForMe.dart';
import 'package:natify/features/User/presentation/widget/postMarketplace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MarketplacePageMe extends ConsumerWidget {
  MarketplacePageMe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String a = "à".tr;
    final notifier = ref.watch(marketPlaceUserStateNotifier);
    String uidMe = FirebaseAuth.instance.currentUser!.uid;
    var requeteId = const Uuid().v1();
    final Map<String, String> _exchangeFormat = {
      'EUR': 'fr_FR',
      'USD': 'en_US',
      'MGA': 'mg_MG',
    };
    Query query = FirebaseFirestore.instance
        .collection('marketplace')
        .where('organizerUid', isEqualTo: uidMe);
    String formatDevise = _exchangeFormat[notifier.currency] ?? "en_US";
    return Scaffold(
        appBar: AppBar(
          title: Text('Gestion annonces'.tr,
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
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.add,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () {
                SlideNavigation.slideToPage(context, CreateAnnonceMarket());
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Consultez et gérez vos annonces : modifiez, mettez à jour ou supprimez-les."
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              FirestorePagination(
                key: ValueKey(requeteId),
                shrinkWrap: true,
                limit: 15, // Defaults to 10.
                isLive: false, // Defaults to false.s
                viewType: ViewType.list,
                physics: NeverScrollableScrollPhysics(),
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
                  String formatDevise =
                      _exchangeFormat[data['currency']] ?? "en_US";
                  String prix =
                      NumberFormat.currency(locale: formatDevise, symbol: '')
                          .format(montant);
                  return InkWell(
                    onTap: () {
                      SlideNavigation.slideToPage(
                        context,
                        ProductDetailScreenMe(
                            categ: data['categorie'],
                            productId: data['uidVente'],
                            emplacement: data['location']['geopoint']),
                      );
                    },
                    child: MarketplacePost(
                      currency: data['currency'],
                      sellerName: data['organizerName'],
                      sellerProfileImage: data['organizerPhoto'],
                      postTitle: data['title'],
                      description: data['description'],
                      categorie: data['categorie'],
                      imageUrls: data['images'],
                      prix: prix,
                    ),
                  );
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 4),
                      Text(
                        textAlign: TextAlign.center,
                        "Actuellement, aucun produit n'est en vente sur Marketplace"
                            .tr,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
