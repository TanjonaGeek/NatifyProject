import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:flutter/material.dart';

class ColorPalette extends StatefulWidget {
  final List<Color> colors;

  const ColorPalette(this.colors, {super.key});

  @override
  _ColorPaletteState createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  @override
  Widget build(BuildContext context) {
    final textStyleModel = TextEditorData.of(context).textStyleModel;
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: textStyleModel.textStyle?.color,
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Icon(
                  Icons.colorize,
                  color: Colors.white,
                ),
              ),
            ),
            ...widget.colors.map((color) => _ColorPicker(color)),
          ],
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color color;

  const _ColorPicker(this.color);

  @override
  Widget build(BuildContext context) {
    final textStyleModel = TextEditorData.read(context).textStyleModel;

    return GestureDetector(
      onTap: () => textStyleModel.editTextColor(color),
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.only(right: 7),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
