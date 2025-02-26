import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Shimmerlistnotification extends StatelessWidget {
  const Shimmerlistnotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
        child: ListView.builder(
          itemCount: 8, // Nombre de notifications à charger
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cercle pour l'image de profil
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Texte simulé pour le contenu de la notification
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ligne de titre simulée
                        Container(
                          width: double.infinity,
                          height: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        // Ligne de texte secondaire simulée
                        Container(
                          width: 150,
                          height: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        // Ligne de date simulée
                        Container(
                          width: 100,
                          height: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}