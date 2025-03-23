import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/widget/detailMarket.dart';
import 'package:natify/features/User/presentation/widget/postMarketplace.dart';

class MarketplacePage extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {
      "sellerName": "iTsena Technology",
      "sellerProfileImage": "https://via.placeholder.com/50",
      "postTitle": "💻 MACBOOK PRO 13\" disponible maintenant !",
      "imageUrls": [
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
      ],
      "likes": 471,
      "comments": 2,
      "shares": 4,
    },
    {
      "sellerName": "Boutique SmartTech",
      "sellerProfileImage": "https://via.placeholder.com/50",
      "postTitle": "📱 iPhone 15 Pro Max - Meilleur prix garanti !",
      "imageUrls": [
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
      ],
      "likes": 300,
      "comments": 10,
      "shares": 5,
    },
    {
      "sellerName": "Store Gamer",
      "sellerProfileImage": "https://via.placeholder.com/50",
      "postTitle": "🎮 PS5 édition digitale - Disponible en stock !",
      "imageUrls": [
        "https://via.placeholder.com/200",
        "https://via.placeholder.com/200",
      ],
      "likes": 150,
      "comments": 5,
      "shares": 2,
    },
  ];

  MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.boxOpen,
                                      color: Colors.black, size: 14),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Categorie',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.locationDot,
                                      color: Colors.black, size: 14),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Essen/Deuthland',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                'Rayon 1km',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                '10.000 MGA a 50.000 MGA',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
            shrinkWrap: true,
            limit: 15, // Defaults to 10.
            isLive: false, // Defaults to false.s
            viewType: ViewType.list,
            bottomLoader: SizedBox(),
            initialLoader: // Section de post
                SizedBox(),
            query: FirebaseFirestore.instance
                .collection('marketplace')
                .orderBy('createdAt', descending: true),
            itemBuilder: (context, documentSnapshot, index) {
              final data = documentSnapshot.data() as Map<String, dynamic>?;
              if (data == null) {
                return Container();
              }
              return InkWell(
                onTap: () {
                  SlideNavigation.slideToPage(
                    context,
                    ProductDetailScreen(
                      productId: data['uidVente'],
                    ),
                  );
                },
                child: MarketplacePost(
                  sellerName: data['organizerName'],
                  sellerProfileImage: data['organizerPhoto'],
                  postTitle: data['title'],
                  description: data['description'],
                  categorie: data['categorie'],
                  imageUrls: data['images'],
                  prix: data['prix'],
                ),
              );
            }),
      ],
    ));
  }
}

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
