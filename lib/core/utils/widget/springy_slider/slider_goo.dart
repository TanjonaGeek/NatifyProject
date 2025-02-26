/// Author: Damodar Lohani
/// profile: https://github.com/lohanidamodar
library;

import 'package:natify/core/utils/widget/springy_slider/slider_clipper.dart';
import 'package:natify/core/utils/widget/springy_slider/slider_controller.dart';
import 'package:flutter/material.dart';

class SliderGoo extends StatelessWidget {
  final SpringySliderController? sliderController;
  final double? paddingTop;
  final double? paddingBottom;
  final Widget? child;

  const SliderGoo({
    super.key,
    this.sliderController,
    this.paddingTop,
    this.paddingBottom,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SliderClipper(
        sliderController: sliderController,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
      ),
      child: child,
    );
  }
}
