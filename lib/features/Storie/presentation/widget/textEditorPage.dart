import 'dart:math';
import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Texteditorpage extends StatefulWidget {
  const Texteditorpage({super.key});

  @override
  State<Texteditorpage> createState() => _TexteditorpageState();
}

class _TexteditorpageState extends State<Texteditorpage> {
  List<Color> _backgroundColor = [
    Colors.blue,
    Colors.red,
  ];
  final fonts = [
    'OpenSans',
    'Billabong',
    'GrandHotel',
    'Oswald',
    'Quicksand',
    'BeautifulPeople',
    'BeautyMountains',
    'BiteChocolate',
    'BlackberryJam',
    'BunchBlossoms',
    'CinderelaRegular',
    'Countryside',
    'Halimun',
    'LemonJelly',
    'QuiteMagicalRegular',
    'Tomatoes',
    'TropicalAsianDemoRegular',
    'VeganStyle',
  ];
  final List<Color> colors = [
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
    Color(0xFF4DB6AC),
    Color(0xFFA1887F),
    Color(0xFF90A4AE),
    Color(0xFF7986CB),
  ];
  TextStyle textStyle = TextStyle(
    fontSize: 30,
    color: Colors.white,
    fontFamily: 'Billabong',
  );
  String text = 'Appuyez pour écrire'.tr;
  TextAlign textAlign = TextAlign.center;
  

    void changeGradientColors() {
    setState(() {
      _backgroundColor = [
        Color.fromARGB(
          255,
          Random().nextInt(256),
          Random().nextInt(256),
          Random().nextInt(256),
        ),
        Color.fromARGB(
          255,
          Random().nextInt(256),
          Random().nextInt(256),
          Random().nextInt(256),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                child: TextEditor(
                  backgroundColor: _backgroundColor,
                  fonts: fonts,
                  text: text,
                  textStyle: textStyle,
                  textAlingment: textAlign,
                  minFontSize: 10,
                  decoration: EditorDecoration(
                    fontFamily: Icon(Icons.title, color: Colors.white),
                    colorPalette: Icon(Icons.palette, color: Colors.white),
                  ),
                  onChangeBackground: changeGradientColors,
                  onEditCompleted: (style, align, text){},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
