import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<String> imageUrls;
  final double imageSize;
  final double overlapOffset;

  const OverlappingAvatars({
    super.key,
    required this.imageUrls,
    this.imageSize = 40,
    this.overlapOffset = 20, // Valeur de chevauchement
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageSize,
      width:
          imageSize + (imageUrls.length - 1) * overlapOffset, // Largeur ajustée
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: imageUrls.asMap().entries.map((entry) {
          int index = entry.key;
          String url = entry.value;
          return Positioned(
            left: index * overlapOffset,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: const DecorationImage(
                      image: AssetImage('assets/noimage.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
