import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProfilePage extends StatelessWidget {
  final String uid;
  const ShimmerProfilePage({super.key, required this.uid});
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      newColorBlueElevate,
                      newColorGreenDarkElevate
                    ],
                  ),
                ),
              ),
              title: Text(
                "",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            leading: SizedBox(),
            actions: [
              SizedBox(),
            ],
          ),
          body: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row principal pour l'avatar, le nom, et le bouton
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Row(
                    children: [
                      // Avatar à gauche
                      Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 30),

                      // Colonne pour le nom et les images superposées
                      // Expanded(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //        SizedBox(height: 1),
                      //       Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.all(Radius.circular(10))
                      //         ),
                      //         width: 160,
                      //         height: 45,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(width: 10,),
                      // Expanded(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //        SizedBox(height: 1),
                      //       Container(
                      //         width: uid == FirebaseAuth.instance.currentUser!.uid ? 70 : 140,
                      //         height: 45,
                      //          decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.all(Radius.circular(10))
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          width: double.infinity,
                          height: 45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Ligne de texte secondaire simulée
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: 150,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Ligne de date simulée
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: 100,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                // Images superposées
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Transform.translate(
                        offset: Offset((-10 * index).toDouble(), 0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Container(
                    width: 130,
                    height: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Grille des éléments en bas
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 3.0,
                            mainAxisExtent: 180),
                    itemCount: 9, // Nombre d'éléments à charger
                    itemBuilder: (context, index) => Container(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
