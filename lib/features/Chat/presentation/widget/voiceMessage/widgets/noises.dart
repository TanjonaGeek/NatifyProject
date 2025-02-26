import 'package:natify/features/Chat/presentation/widget/voiceMessage/widgets/single_noise.dart';
import 'package:flutter/material.dart';

/// A widget that represents a collection of noises.
///
/// This widget is used to display a collection of noises in the UI.
/// It is typically used in the context of a voice message player.
class Noises extends StatelessWidget {
  const Noises({
    super.key,
    required this.rList,
    required this.activeSliderColor,
  });

  /// A list of noises value.
  final List<double> rList;

  /// The color of the active slider.
  final Color activeSliderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: rList
          .map(
            (e) => Flexible(
              child: SingleNoise(
                activeSliderColor: activeSliderColor,
                height: e,
              ),
            ),
          )
          .toList(),
    );
  }
}
