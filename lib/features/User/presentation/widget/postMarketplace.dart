import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:natify/core/utils/colors.dart';

class MarketplacePost extends StatelessWidget {
  final String sellerName;
  final String sellerProfileImage;
  final String postTitle;
  final String description;
  final String categorie;
  final List<dynamic> imageUrls;
  final String prix;
  final String currency;

  const MarketplacePost({
    super.key,
    required this.sellerName,
    required this.sellerProfileImage,
    required this.postTitle,
    required this.description,
    required this.categorie,
    required this.imageUrls,
    required this.prix,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image à gauche qui prend un bon espace
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: CachedNetworkImage(
              imageUrl: imageUrls.first,
              width: 120, // Ajuste selon le besoin
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: Colors.red),
            ),
          ),

          /// Texte à droite qui prend le reste de la place
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postTitle.replaceAll('\n', ' ').trim(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    categorie.replaceAll('\n', ' ').trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "${prix} ${currency}",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // /// Bouton favoris à droite
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: Icon(Icons.favorite_border, color: Colors.red),
          // ),
        ],
      ),
    );
  }

  Widget _actionButton(Widget icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: icon,
      label: Text(label,
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
    );
  }
}
