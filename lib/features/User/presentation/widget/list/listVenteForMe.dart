import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/widget/detailMarketForMe.dart';
import 'package:natify/features/User/presentation/widget/postMarketplace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class listVenteForme extends StatefulWidget {
  const listVenteForme({super.key});

  @override
  State<listVenteForme> createState() => _listVenteFormeState();
}

class _listVenteFormeState extends State<listVenteForme> {
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
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FirestorePagination(
        key: ValueKey(requeteId),
        limit: 15, // Defaults to 10.
        isLive: false, // Defaults to false
        viewType: ViewType.list,
        physics: AlwaysScrollableScrollPhysics(),
        bottomLoader: SizedBox(),
        initialLoader: // Section de post
            Center(
          child: Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              )),
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
          String formatDevise = _exchangeFormat[data['currency']] ?? "en_US";
          String prix = NumberFormat.currency(locale: formatDevise, symbol: '')
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
                // extentRatio: 0.3,
                motion:
                    StretchMotion(), // Utilisation de DrawerMotion pour un effet de glissement différent
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      SlideNavigation.slideToPage(
                        context,
                        ProductDetailScreenMe(
                            categ: data['categorie'],
                            productId: data['uidVente'],
                            emplacement: data['location']['geopoint']),
                      );
                    },
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    label: 'editer'.tr,
                  ),
                  SlidableAction(
                    onPressed: (_) => showCustomDialog(
                      context: context,
                      icon: Icons.warning,
                      iconColor: Colors.red,
                      title: "Supprimer_cet_élément",
                      message: "action_irréversible.",
                      confirmText: "Oui_Supprimer".tr,
                      cancelText: "annuler".tr,
                      isConfirmation: true,
                      onConfirm: () {
                        _deleteSale(data['uidVente'].toString());
                      },
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
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
                "Aucun_produit_disponible".tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 4),
              Text(
                textAlign: TextAlign.center,
                "Actuellement_aucun_produit".tr,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
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
                "${title}".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Sous-titre
              Text(
                "${message}".tr,
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
