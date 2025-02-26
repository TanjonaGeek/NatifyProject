import 'package:natify/features/Storie/presentation/widget/textEditor/src/font_option_model.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:flutter/material.dart';

class FontOptionSwitch extends StatefulWidget {
  final Widget? fontFamilySwitch;
  final Widget? colorPaletteSwitch;

  const FontOptionSwitch({super.key, this.fontFamilySwitch, this.colorPaletteSwitch});

  @override
  _FontOptionSwitch createState() => _FontOptionSwitch();
}

class _FontOptionSwitch extends State<FontOptionSwitch> {
  @override
  Widget build(BuildContext context) {
    final model = TextEditorData.of(context).fontOptionModel;
    return GestureDetector(
      onTap: () => model.changeFontOptionStatus(model.status),
      child: model.status == FontOptionStatus.fontFamily
          ? (widget.colorPaletteSwitch ?? _ColorOption())
          : (widget.fontFamilySwitch ?? _FontOption()),
    );
  }
}

class _ColorOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.5),
        border: Border.all(color: Colors.white, width: 1.5),
        gradient: SweepGradient(
          colors: [
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.red,
            Colors.blue,
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1],
        ),
      ),
    );
  }
}

class _FontOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.5),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          'A',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
