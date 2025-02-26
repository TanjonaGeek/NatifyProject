/**
 * Codes for stringy widgets and all corresponding widgets related to this
 * are taken from Fluttery UI Challenges 
 * (https://github.com/matthew-carroll/flutter_ui_challenge_springy_slider)
 * Check out the repository and give it a start
 */
/// Author: Damodar Lohani
/// profile: https://github.com/lohanidamodar
library;


import 'package:natify/core/utils/widget/springy_slider/slider_controller.dart';
import 'package:natify/core/utils/widget/springy_slider/slider_dragger.dart';
import 'package:natify/core/utils/widget/springy_slider/slider_goo.dart';
import 'package:natify/core/utils/widget/springy_slider/slider_marks.dart';
import 'package:natify/core/utils/widget/springy_slider/slider_points.dart';
import 'package:natify/core/utils/widget/springy_slider/slider_state.dart';
import 'package:flutter/material.dart';

class SpringySlider extends StatefulWidget {
  final int? markCount;
  final Color? positiveColor;
  final Color? negativeColor;
  final Function(double)? onSliderValueChanged;

  const SpringySlider({
    super.key,
    this.markCount,
    this.positiveColor,
    this.negativeColor,
    this.onSliderValueChanged, // Ajout du paramètre
  });

  @override
  _SpringySliderState createState() => _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider>
    with TickerProviderStateMixin {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;

  SpringySliderController? sliderController;

  @override
  void initState() {
    super.initState();
    sliderController = SpringySliderController(
      sliderPercent: 0.14,
      vsync: this,
    )..addListener(() {
        setState(() {});
        widget.onSliderValueChanged
            ?.call(sliderController!.sliderValue!.toDouble());
      });
  }

  @override
  Widget build(BuildContext context) {
    print('le age est $sliderController');
    if (sliderController!.state == SpringySliderState.springing) {}

    return SliderDragger(
      sliderController: sliderController,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
      child: Stack(
        children: <Widget>[
          SliderMarks(
            markCount: widget.markCount,
            markColor: widget.positiveColor,
            backgroundColor: widget.negativeColor,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          SliderGoo(
            sliderController: sliderController,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
            child: SliderMarks(
              markCount: widget.markCount,
              markColor: widget.negativeColor,
              backgroundColor: widget.positiveColor,
              paddingTop: paddingTop,
              paddingBottom: paddingBottom,
            ),
          ),
          SliderPoints(
            sliderController: sliderController,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
//          new SliderDebug(
//            sliderPercent: sliderController.state == SpringySliderState.dragging
//                ? sliderController.draggingPercent
//                : sliderPercent,
//            paddingTop: paddingTop,
//            paddingBottom: paddingBottom,
//          ),
        ],
      ),
    );
  }
}
