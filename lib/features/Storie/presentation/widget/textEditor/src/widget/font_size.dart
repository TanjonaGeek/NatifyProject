import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:flutter/material.dart';

class FontSize extends StatelessWidget {
  final double minFontSize;
  final double maxFontSize;

  const FontSize({super.key, required this.minFontSize, required this.maxFontSize});

  @override
  Widget build(BuildContext context) {
    final model = TextEditorData.of(context).textStyleModel;
    return RotatedBox(
      quarterTurns: 3,
      child: Slider(
        value: model.textStyle?.fontSize ?? minFontSize,
        min: minFontSize,
        max: maxFontSize,
        divisions: ((maxFontSize - minFontSize) * 10).toInt(),
        activeColor: Colors.white,
        inactiveColor: Colors.white,
        onChanged: (double value) => model.editFontSize(value),
      ),
    );
  }
}
