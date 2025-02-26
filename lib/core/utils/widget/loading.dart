import 'package:flutter/material.dart';
import 'package:natify/core/utils/colors.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 45,
        height: 45,
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircularProgressIndicator(
            color: kPrimaryColor, // Couleur du loader bleu
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
