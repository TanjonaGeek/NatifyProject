import 'package:natify/features/Storie/presentation/widget/textEditor/src/font_option_model.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:flutter/material.dart';

class FontFamily extends StatefulWidget {
  final List<FontFamilyModel> fonts;

  const FontFamily(this.fonts, {super.key});

  @override
  _FontFamilyState createState() => _FontFamilyState();
}

class _FontFamilyState extends State<FontFamily> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.fonts
              .map((fontModel) =>
                  _FontFamilyPicker(fontModel.font, fontModel.isSelected))
              .toList(),
        ),
      ),
    );
  }
}

class _FontFamilyPicker extends StatelessWidget {
  final String font;
  final bool isSelected;

  const _FontFamilyPicker(this.font, this.isSelected);

  @override
  Widget build(BuildContext context) {
    final fontOptionModel = TextEditorData.read(context).fontOptionModel;

    return GestureDetector(
      onTap: () => fontOptionModel.selectFontFamily(font),
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.only(right: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected ? Colors.white : Colors.black45,
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white,
              fontFamily: font,
            ),
          ),
        ),
      ),
    );
  }
}
