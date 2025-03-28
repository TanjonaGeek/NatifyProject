import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/createannoncemarket.dart';
import 'package:natify/features/User/presentation/widget/detailMarketForMe.dart';
import 'package:natify/features/User/presentation/widget/postMarketplace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MarketplacePageMe extends ConsumerStatefulWidget {
  MarketplacePageMe({super.key});

  @override
  ConsumerState<MarketplacePageMe> createState() => _MarketplacePageMeState();
}

class _MarketplacePageMeState extends ConsumerState<MarketplacePageMe>
    with SingleTickerProviderStateMixin {
  String requeteId = Uuid().v1();
  String a = "à".tr;
  Query query = FirebaseFirestore.instance
      .collection('marketplace')
      .where('organizerUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  void _deleteSale(String venteId) async {
    try {
      if (venteId.isEmpty) {
        return;
      }
      await FirebaseFirestore.instance
          .collection('marketplace')
          .doc(venteId)
          .delete()
          .then((onValue) {
        setState(() {
          requeteId = Uuid().v1();
        });
      });
    } catch (e) {
      print("Erreur lors de la suppression : $e");
    }
  }

  Future<void> _refresh() async {
    setState(() {
      requeteId = Uuid().v1();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
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
                  isLive: false, // Defaults to false
                  viewType: ViewType.list,
                  physics: NeverScrollableScrollPhysics(),
                  bottomLoader: SizedBox(),
                  initialLoader: // Section de post
                      SizedBox(),
                  query: query,
                  itemBuilder: (context, documentSnapshot, index) {
                    final data =
                        documentSnapshot.data() as Map<String, dynamic>?;
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
                      child: Slidable(
                        key: ValueKey(data['uidVente']),
                        endActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion:
                              StretchMotion(), // Utilisation de DrawerMotion pour un effet de glissement différent
                          children: [
                            SlidableAction(
                              onPressed: (_) => showCustomDialog(
                                context: context,
                                icon: Icons.warning,
                                iconColor: Colors.red,
                                title: "Supprimer cette element ?",
                                message:
                                    "Êtes-vous sûr de vouloir supprimer cette element ? Cette action est irréversible.",
                                confirmText: "Oui, Supprimer",
                                cancelText: "Cancel",
                                isConfirmation: true,
                                onConfirm: () {
                                  _deleteSale(data['uidVente'].toString());
                                },
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              label: 'supprimer'.tr,
                            ),
                          ],
                        ),
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
          ),
        ));
  }
}

void showCustomDialog({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  required bool isConfirmation,
  VoidCallback? onConfirm,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône circulaire
              CircleAvatar(
                radius: 30,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),

              // Titre
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Sous-titre
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),

              // Affichage conditionnel des boutons
              isConfirmation
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Bouton Annuler
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            cancelText,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),

                        // Bouton Confirmer
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (onConfirm != null) {
                              onConfirm();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            confirmText,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: Text(
                        confirmText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      );
    },
  );
}
