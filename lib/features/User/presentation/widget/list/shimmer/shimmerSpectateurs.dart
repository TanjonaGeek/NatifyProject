import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingSpectators extends StatelessWidget {
  const ShimmerLoadingSpectators({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
        itemCount: 1, // Exemple avec 5 éléments
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo de profil circulaire
               Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
               ),
                const SizedBox(width: 16),

                // Nom de l'utilisateur
                Expanded(
                  child: Container(
                    height: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}