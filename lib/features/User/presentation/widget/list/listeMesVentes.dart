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
import 'package:natify/features/User/presentation/widget/list/listVenteForMe.dart';
import 'package:natify/features/User/presentation/widget/postMarketplace.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MarketplacePageMe extends StatelessWidget {
  MarketplacePageMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gestion_annonces'.tr,
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
              children: [
                Text(
                  "Consultez_gérez_annonces".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Expanded(child: listVenteForme()),
              ],
            )));
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
