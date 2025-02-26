import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF1198d1);
const kSecondaryColor = Color(0xFFFE9901);
const kContentColorLightTheme = Color(0xFF1D1D35);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kWarninngColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);
const kDefaultPadding = 20.0;

const Color gradientStart = Color(0xFFfbab66);
const Color gradientEnd = Color(0xFFf7418c);

// const Color newColorGrey = const Color(0xFFF0F4FD);
// const Color newColorGreyElevate = const Color(0xFFE2E8F4);
// const Color newColorBlueShadow = const Color(0xFF86A8E9);
// const Color newColorBlueElevate = const Color(0xFF447CE4);
const Color newColorGrey = Color(0xFFF0F4FD);
const Color newColorGreyElevate = Color(0xFFE2E8F4);
const Color newColorBlueShadow = Color(0xFF0d649a);
const Color newColorBlueElevate = Color(0xFF03a8e8);
const Color newColorGreenDarkElevate = Color(0xFF14334b);

const primaryGradient = LinearGradient(
  colors: [newColorBlueElevate, newColorGreenDarkElevate],
  stops: [0.0, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const primaryGradient1 = LinearGradient(
  colors: [gradientStart, gradientStart],
  stops: [0.0, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const chatBubbleGradient = LinearGradient(
  colors: [Color(0xFFFD60A3), Color(0xFFFF8961)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const chatBubbleGradient2 = LinearGradient(
  colors: [Color(0xFFf4e3e3), Color(0xFFf4e3e3)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
