import 'package:natify/features/Storie/presentation/widget/textEditor/src/text_style_model.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:flutter/material.dart';

class TextAlignment extends StatelessWidget {
  final Widget? left;
  final Widget? center;
  final Widget? right;

  const TextAlignment({super.key, this.left, this.center, this.right});

  void _onChangeAlignment(TextStyleModel textStyleModel) {
    switch (textStyleModel.textAlign) {
      case TextAlign.left:
        textStyleModel.editTextAlinment(TextAlign.center);
        break;
      case TextAlign.center:
        textStyleModel.editTextAlinment(TextAlign.right);
        break;
      default:
        textStyleModel.editTextAlinment(TextAlign.left);
    }
  }

  Widget _mapTextAlignToWidget(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return left ?? Icon(Icons.format_align_left, color: Colors.white);
      case TextAlign.center:
        return center ?? Icon(Icons.format_align_center, color: Colors.white);
      default:
        return right ?? Icon(Icons.format_align_right, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = TextEditorData.of(context).textStyleModel;
    return GestureDetector(
      onTapUp: (_) => _onChangeAlignment(model),
      child: _mapTextAlignToWidget(model.textAlign!),
    );
  }
}
