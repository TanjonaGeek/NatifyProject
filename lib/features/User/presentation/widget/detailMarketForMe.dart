import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/pages/editerannocemarket.dart';
import 'package:natify/features/User/presentation/widget/list/visualisrMarketPlaceInMaps.dart';
import 'package:uuid/uuid.dart';

class ProductDetailScreenMe extends StatefulWidget {
  final String productId;
  final GeoPoint emplacement;
  final String categ;

  ProductDetailScreenMe(
      {Key? key,
      required this.productId,
      required this.emplacement,
      required this.categ})
      : super(key: key);

  @override
  State<ProductDetailScreenMe> createState() => _ProductDetailScreenMeState();
}

class _ProductDetailScreenMeState extends State<ProductDetailScreenMe> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  final ValueNotifier<String> _address = ValueNotifier<String>("");
  final ValueNotifier<String> _addressNews = ValueNotifier<String>("");
  final ValueNotifier<GeoPoint> _geoPoint = ValueNotifier(GeoPoint(0, 0));
  late Future<List<QueryDocumentSnapshot>> _futureProducts;
  String requeteId = Uuid().v1();
  final Map<String, String> _exchangeFormat = {
    'EUR': 'fr_FR',
    'USD': 'en_US',
    'MGA': 'mg_MG',
  };
  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.emplacement.latitude, widget.emplacement.longitude);
      if (placemarks.isNotEmpty) {
        String codePostal = placemarks.first.postalCode.toString() ?? '';
        String locality = placemarks.first.subLocality.toString() ?? '';
        String administrativeArea =
            placemarks.first.administrativeArea.toString() ?? '';
        String adresse = "${codePostal} $locality $administrativeArea";
        _address.value = adresse;
        _geoPoint.value = widget.emplacement;
      }
    } catch (e) {
      _address.value = "";
    }
  }

  Future<void> _getAddressFromCoordinatesReload(GeoPoint pos) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        String codePostal = placemarks.first.postalCode.toString() ?? '';
        String locality = placemarks.first.subLocality.toString() ?? '';
        String administrativeArea =
            placemarks.first.administrativeArea.toString() ?? '';
        String adresse = "${codePostal} $locality $administrativeArea";
        if (_address.value != adresse) {
          _address.value = adresse;
          _geoPoint.value = pos;
        }
      }
    } catch (e) {}
  }

  Future<List<QueryDocumentSnapshot>> fetchProductsSimilar() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('marketplace')
        .where('categorie', isEqualTo: widget.categ)
        .where('uidVente', isNotEqualTo: widget.productId)
        .orderBy('createdAt', descending: true)
        .limit(5) // 🔥 Limite à 5 produits
        .get();
    return querySnapshot.docs;
  }

  Future<void> _refresh() async {
    setState(() {
      requeteId = Uuid().v1();
    });
  }

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates();
    _futureProducts = fetchProductsSimilar();
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''.tr, style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: FirestorePagination(
                key: ValueKey(requeteId),
                physics: NeverScrollableScrollPhysics(),
                limit: 1, // Defaults to 10.
                isLive: false, // Defaults to false.s
                viewType: ViewType.list,
                bottomLoader: SizedBox(),
                shrinkWrap: true,
                initialLoader: // Section de post
                    Center(
                        child: Container(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ))),
                query: FirebaseFirestore.instance
                    .collection('marketplace')
                    .where('uidVente', isEqualTo: widget.productId),
                itemBuilder: (context, documentSnapshot, index) {
                  final product =
                      documentSnapshot.data() as Map<String, dynamic>?;
                  if (product == null) {
                    return Container();
                  }
                  GeoPoint emp = product['location']['geopoint'];
                  // Appelle une seule fois l'adresse
                  Future.microtask(() => _getAddressFromCoordinatesReload(emp));
                  double montant = (product['prix'] is int)
                      ? product['prix'].toDouble()
                      : double.tryParse(product['prix'].toString()) ?? 0.0;

                  String Prixformatted =
                      NumberFormat.currency(locale: 'mg_MG').format(montant);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 250,
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: product['images'].length,
                              onPageChanged: (index) =>
                                  _currentIndex.value = index,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: product['images'][index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade100,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error, color: Colors.red),
                                );
                              },
                            ),
                            // === IMAGE COUNT (en bas à droite) ===
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: ValueListenableBuilder<int>(
                                valueListenable: _currentIndex,
                                builder: (context, value, _) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      "${value + 1} / ${product['images'].length}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      // Titre & Prix
                      Text(
                        product['title'],
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Prixformatted,
                        style: TextStyle(fontSize: 18, color: kPrimaryColor),
                      ),
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : SizedBox(height: 5);
                          }),
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : Row(
                                    children: [
                                      SizedBox(
                                        width: 3,
                                      ),
                                      FaIcon(FontAwesomeIcons.locationDot,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          size: 15),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: Text("${_address.value}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16)),
                                      ),
                                    ],
                                  );
                          }),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.boxOpen,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              size: 15),
                          SizedBox(
                            width: 9,
                          ),
                          Flexible(
                            child: Text(product['categorie'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Bouton de contact
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => EditerAnnonceMarket(
                                uidVente: product['uidVente'],
                                status: product['status'],
                                categorie: product['categorie'],
                                currency: product['currency'],
                                description: product['description'],
                                title: product['title'],
                                price: product['prix'].toString(),
                                photoUrl: List<String>.from(product['images']),
                                adresse: _address.value,
                                emplacement: product['location']['geopoint'],
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
                                'assets/editer-le-texte.png',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            Flexible(
                              child: Text("Mettre_a_jour_annonce".tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      // Description
                      Text("description".tr,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          )),
                      SizedBox(height: 5),
                      Text(product['description'],
                          style: TextStyle(
                            fontSize: 16,
                          )),

                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey.shade300,
                      ),

                      SizedBox(height: 2),

                      // Description
                      Text("Vendeur".tr,
                          maxLines: 1,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
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
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        title: Text(product['organizerName']),
                        // subtitle: Text("Membre depuis dsfsfsdfdsf"),
                      ),

                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : SizedBox(height: 10);
                          }),
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : Divider(
                                    color: Colors.grey.shade300,
                                  );
                          }),
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : SizedBox(height: 2);
                          }),
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : Text("Emplacement".tr,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 18,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold));
                          }),

                      // Description
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : SizedBox(height: 5);
                          }),
                      ValueListenableBuilder<String>(
                          valueListenable: _address,
                          builder: (context, value, _) {
                            return value.isEmpty
                                ? SizedBox.shrink()
                                : ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          'assets/maps2.jpg',
                                          width: double.infinity,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                        ValueListenableBuilder<GeoPoint>(
                                            valueListenable: _geoPoint,
                                            builder: (context, value, _) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Position positionNews =
                                                      Position(
                                                    latitude: value.latitude,
                                                    longitude: value.longitude,
                                                    accuracy:
                                                        0.0, // Précision, vous pouvez ajuster cette valeur
                                                    altitude:
                                                        0.0, // Altitude par défaut
                                                    heading:
                                                        0.0, // Direction par défaut
                                                    speed:
                                                        0.0, // Vitesse par défaut
                                                    speedAccuracy:
                                                        0.0, // Précision de la vitesse
                                                    timestamp: DateTime.now(),
                                                    altitudeAccuracy:
                                                        0.0, // Ajoutez l'altitudeAccuracy par défaut
                                                    headingAccuracy: 0.0,
                                                  );
                                                  SlideNavigation.slideToPage(
                                                    context,
                                                    ViewMapsMarketPlace(
                                                      currentPosition:
                                                          positionNews,
                                                      lieuAdress:
                                                          _address.value,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 90,
                                                  color: Colors.black.withOpacity(
                                                      0.2), // Ajoute un fond sombre
                                                ),
                                              );
                                            }),
                                        ValueListenableBuilder<GeoPoint>(
                                            valueListenable: _geoPoint,
                                            builder: (context, value, _) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Position positionNews =
                                                      Position(
                                                    latitude: value.latitude,
                                                    longitude: value.longitude,
                                                    accuracy:
                                                        0.0, // Précision, vous pouvez ajuster cette valeur
                                                    altitude:
                                                        0.0, // Altitude par défaut
                                                    heading:
                                                        0.0, // Direction par défaut
                                                    speed:
                                                        0.0, // Vitesse par défaut
                                                    speedAccuracy:
                                                        0.0, // Précision de la vitesse
                                                    timestamp: DateTime.now(),
                                                    altitudeAccuracy:
                                                        0.0, // Ajoutez l'altitudeAccuracy par défaut
                                                    headingAccuracy: 0.0,
                                                  );
                                                  SlideNavigation.slideToPage(
                                                    context,
                                                    ViewMapsMarketPlace(
                                                      currentPosition:
                                                          positionNews,
                                                      lieuAdress:
                                                          _address.value,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 90,
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Text(
                                                        "Appuyer_voir_emplacement"
                                                            .tr,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ), // Ajoute un fond sombre
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  );
                          }),
                      SizedBox(height: 2),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
