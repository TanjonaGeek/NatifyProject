import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:natify/features/Chat/presentation/pages/messageDetail.dart';
import 'package:natify/features/User/presentation/pages/userProfilePage.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  // Fonction pour récupérer l'adresse depuis les coordonnées
  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      // Récupérer l'adresse en utilisant la latitude et la longitude
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark placemark =
          placemarks[0]; // Vous pouvez aussi traiter plusieurs résultats ici

      // Retourner une adresse lisible, par exemple : "Paris, France"
      return '${placemark.locality}, ${placemark.country}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    int maxImages = 3;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Marketplaces'.tr,
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
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
      ),
      body: FirestorePagination(
        physics: AlwaysScrollableScrollPhysics(),
        limit: 1, // Defaults to 10.
        isLive: false, // Defaults to false.s
        viewType: ViewType.list,
        bottomLoader: SizedBox(),
        initialLoader: // Section de post
            SizedBox(),
        query: FirebaseFirestore.instance
            .collection('marketplace')
            .where('uidVente', isEqualTo: productId),
        itemBuilder: (context, documentSnapshot, index) {
          final product = documentSnapshot.data() as Map<String, dynamic>?;
          if (product == null) {
            return Container();
          }
          GeoPoint emplacement = product['location']['geopoint'];
          double montant =
              double.tryParse(product['prix']) ?? 0.0; // Convertir en double
          String Prixformatted =
              NumberFormat.currency(locale: 'mg_MG').format(montant);
          // Récupérer l'adresse
          Future<String> address = _getAddressFromCoordinates(
              emplacement.latitude, emplacement.longitude);

          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 images par ligne
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: product['images'].length > maxImages
                      ? maxImages + 1
                      : product['images'].length,
                  itemBuilder: (context, index) {
                    bool isLast = index == 3 && product['images'].length > 4;
                    if (index == maxImages &&
                        product['images'].length > maxImages) {
                      // Si plus d'images que maxImages, afficher "+X"
                      int remaining = product['images'].length - maxImages;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: product['images'][maxImages],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Text(
                              "+$remaining",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: product['images'][index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                // Titre & Prix
                Text(
                  product['title'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  Prixformatted,
                  style: TextStyle(fontSize: 18, color: kPrimaryColor),
                ),
                SizedBox(height: 5),
                FutureBuilder<String>(
                  future: address,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox.shrink();
                    }
                    if (snapshot.hasError) {
                      return SizedBox.shrink();
                    }
                    return snapshot.data!.isEmpty
                        ? SizedBox.shrink()
                        : Row(
                            children: [
                              FaIcon(FontAwesomeIcons.locationDot,
                                  color: Colors.red, size: 15),
                              SizedBox(
                                width: 5,
                              ),
                              Text("${snapshot.data}",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                            ],
                          );
                  },
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.boxOpen,
                        color: Colors.black, size: 15),
                    SizedBox(
                      width: 5,
                    ),
                    Text(product['categorie'],
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 10),
                // Bouton de contact
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => MessageDetail(
                          urlPhoto: product['organizerPhoto'],
                          uid: product['organizerUid'],
                          name: product['organizerName'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero), // Pas d'arrondi
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/discuter.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text("Contacter maintenant",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // Description
                Text("Description",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(product['description'], style: TextStyle(fontSize: 16)),

                SizedBox(height: 10),
                Divider(
                  color: Colors.grey.shade300,
                ),

                SizedBox(height: 2),

                // Description
                Text("Vendeur",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),

                // Infos du vendeur
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipOval(
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: product['organizerPhoto'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: Text(product['organizerName']),
                  // subtitle: Text("Membre depuis dsfsfsdfdsf"),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(uid: product['organizerUid']),
                        ),
                      );
                    },
                    icon: FaIcon(FontAwesomeIcons.chevronRight, size: 14),
                  ),
                  // trailing: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: kPrimaryColor,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.zero), // Pas d'arrondi
                  //     ),
                  //     onPressed: () {},
                  //     child: Text(
                  //       "Voir profile",
                  //       style: TextStyle(
                  //           color: Colors.white, fontWeight: FontWeight.bold),
                  //     )),
                ),
                SizedBox(height: 10),
                Divider(
                  color: Colors.grey.shade300,
                ),
                if (emplacement.latitude != 0 && emplacement.longitude != 0)
                  Text("Emplacement",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                // Utilisez FutureBuilder ou StreamBuilder ici pour attendre le chargement des données
                if (emplacement.latitude != 0 && emplacement.longitude != 0)
                  FutureBuilder(
                    future: Future.delayed(
                        Duration(seconds: 1),
                        () =>
                            emplacement), // Simuler le délai de récupération de données
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          width: double.infinity,
                          height: 120,
                          color: Colors.grey.shade200,
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur de chargement'));
                      }

                      final locationData = snapshot.data as GeoPoint?;
                      return !snapshot.hasData
                          ? Container(
                              width: double.infinity,
                              height: 120,
                              color: Colors.grey.shade200,
                            )
                          : Container(
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      zoomControlsEnabled: false,
                                      scrollGesturesEnabled: true,
                                      rotateGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      myLocationButtonEnabled: false,
                                      initialCameraPosition: CameraPosition(
                                        target: locationData != null
                                            ? LatLng(locationData.latitude,
                                                locationData.longitude)
                                            : LatLng(0.0, 0.0),
                                        zoom: 10.5,
                                      ),
                                      markers: locationData != null
                                          ? Set.from([
                                              Marker(
                                                markerId:
                                                    MarkerId('productMarker'),
                                                position: LatLng(
                                                    locationData.latitude,
                                                    locationData.longitude),
                                              ),
                                            ])
                                          : Set(),
                                    ),
                                    if (snapshot.hasData)
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FutureBuilder<String>(
                                                  future: address,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return SizedBox.shrink();
                                                    }
                                                    if (snapshot.hasError) {
                                                      return SizedBox.shrink();
                                                    }
                                                    return Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        FaIcon(
                                                            FontAwesomeIcons
                                                                .mapPin,
                                                            color: Colors.red,
                                                            size: 14),
                                                        SizedBox(width: 5),
                                                        Text('${snapshot.data}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _optionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.black),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
