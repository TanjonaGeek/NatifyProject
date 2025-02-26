import 'package:flutter/material.dart';

enum TextBackgroundStatus { enable, exchange, disable }

class TextStyleModel extends ChangeNotifier {
  String text;
  TextStyle? textStyle;
  TextAlign? textAlign;
  late TextBackgroundStatus textBackgroundStatus;

  TextStyleModel(
    this.text, {
    this.textAlign,
    this.textStyle,
  }) {
    textStyle = textStyle ?? TextStyle(fontSize: 10);
    textAlign = textAlign ?? TextAlign.center;

    textBackgroundStatus = textStyle!.backgroundColor == null ||
            textStyle!.backgroundColor == Colors.transparent
        ? TextBackgroundStatus.disable
        : TextBackgroundStatus.enable;
  }

  void editTextAlinment(TextAlign value) {
    textAlign = value;

    notifyListeners();
  }

  void editTextColor(Color value, {bool changeBackground = false}) {
    if (textBackgroundStatus == TextBackgroundStatus.disable) {
      textStyle = textStyle!
          .copyWith(color: value, backgroundColor: Colors.transparent);
    } else if (textBackgroundStatus == TextBackgroundStatus.enable) {
      textStyle = textStyle!
          .copyWith(color: _adjustColor(value), backgroundColor: value);
    } else {
      if (changeBackground) {
        // Exchange color and background if background status is changing
        textStyle = textStyle!.copyWith(
            color: textStyle!.backgroundColor,
            backgroundColor: textStyle!.color);
      } else {
        textStyle = textStyle!
            .copyWith(color: value, backgroundColor: _adjustColor(value));
      }
    }

    notifyListeners();
  }

  void editFontSize(double value) {
    textStyle = textStyle!.copyWith(fontSize: value);

    notifyListeners();
  }

  void changeFontFamily(String value) {
    textStyle = textStyle!.copyWith(fontFamily: value);

    notifyListeners();
  }

  void changeTextBackground() {
    switch (textBackgroundStatus) {
      case TextBackgroundStatus.disable:
        textBackgroundStatus = TextBackgroundStatus.enable;
        break;
      case TextBackgroundStatus.enable:
        textBackgroundStatus = TextBackgroundStatus.exchange;
        break;
      default:
        textBackgroundStatus = TextBackgroundStatus.disable;
    }

    editTextColor(textStyle!.color ?? Colors.black, changeBackground: true);
  }

  Color _adjustColor(Color? color, [double amount = 0.3]) {
    assert(amount >= 0 && amount <= 1);

    if (color == Colors.black) {
      return Colors.white;
    } else if (color == Colors.white) {
      return Colors.black;
    }

    final hsl = HSLColor.fromColor(color!);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
