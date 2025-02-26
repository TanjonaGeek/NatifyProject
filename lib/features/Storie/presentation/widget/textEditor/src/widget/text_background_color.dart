import 'package:natify/features/Storie/presentation/widget/textEditor/src/text_style_model.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:flutter/material.dart';

class TextBackgroundColor extends StatelessWidget {
  final Widget? enableWidget;
  final Widget? disableWidget;

  const TextBackgroundColor({super.key, this.enableWidget, this.disableWidget});

  @override
  Widget build(BuildContext context) {
    final model = TextEditorData.of(context).textStyleModel;
    return GestureDetector(
      onTap: () => model.changeTextBackground(),
      child: model.textBackgroundStatus != TextBackgroundStatus.disable
          ? enableWidget ?? _SwitchButton(enabled: true)
          : disableWidget ?? _SwitchButton(enabled: false),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  final bool enabled;
  const _SwitchButton({this.enabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: !enabled ? null : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Icon(
        Icons.format_bold,
        size: 20,
        color: !enabled ? Colors.white : Colors.black,
      ),
    );
  }
}
