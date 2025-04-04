import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:natify/core/utils/colors.dart';

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String currency;
  final GeoPoint emplacement;
  final bool isFav;
  final int nbrFav;

  ProductCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.currency,
    required this.emplacement,
    required this.isFav,
    required this.nbrFav,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String _address = "";
  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates();
  }

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
        setState(() {
          _address = adresse;
        });
      }
    } catch (e) {
      setState(() {
        _address = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade100,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
                Positioned(
                    top: 10,
                    right: 5,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 4),
                        child: Row(
                          children: [
                            if (widget.nbrFav > 0)
                              Text(
                                '${widget.nbrFav}',
                                style: TextStyle(color: Colors.white),
                              ),
                            if (widget.nbrFav > 0)
                              SizedBox(
                                width: 5,
                              ),
                            widget.isFav
                                ? FaIcon(FontAwesomeIcons.solidHeart,
                                    color: Colors.red, size: 15)
                                : FaIcon(FontAwesomeIcons.heart,
                                    color: Colors.white, size: 15),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _address.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  widget.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text("${widget.price} ${widget.currency}",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
