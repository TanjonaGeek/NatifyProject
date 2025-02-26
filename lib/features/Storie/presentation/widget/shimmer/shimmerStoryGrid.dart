import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingCard extends StatelessWidget {
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.grey[200], // Background color to show shimmer effect
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1), // Add border here
        ),
        child: Stack(
          children: [
            // CircleAvatar placeholder
            Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                ),
              ),
            ),
            // Name placeholder
            // Positioned(
            //   bottom: 15,
            //   left: 10,
            //   child: Container(
            //     width: 110,
            //     height: 15,
            //     color: Colors.grey[300],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
