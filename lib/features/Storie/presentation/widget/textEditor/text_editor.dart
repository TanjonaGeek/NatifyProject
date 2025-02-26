// library text_editor;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/features/Chat/data/datasources/local/data_sources_chat_impl..dart';
import 'package:natify/features/Storie/presentation/provider/storie_provider.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/font_option_model.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/text_style_model.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/widget/color_palette.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/widget/font_family.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/widget/font_option_switch.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/widget/font_size.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/src/widget/text_alignment.dart';
import 'package:natify/features/Storie/presentation/widget/textEditor/text_editor_data.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'src/widget/text_background_color.dart';

/// Instagram like text editor
/// A flutter widget that edit text style and text alignment
///
/// You can pass your text style to the widget
/// and then get the edited text style
class TextEditor extends ConsumerStatefulWidget {
  /// Editor's font families
  final List<String> fonts;

  /// After edit process completed, [onEditCompleted] callback will be called.
  final void Function(TextStyle, TextAlign, String) onEditCompleted;

  // change a backgroud textEditor in color Random
  final void Function() onChangeBackground;

  /// [onTextAlignChanged] will be called after [textAlingment] prop has changed
  final ValueChanged<TextAlign>? onTextAlignChanged;

  /// [onTextStyleChanged] will be called after [textStyle] prop has changed
  final ValueChanged<TextStyle>? onTextStyleChanged;

  /// [onTextChanged] will be called after [text] prop has changed
  final ValueChanged<String>? onTextChanged;

  /// The text alignment
  final TextAlign? textAlingment;

  /// The text style
  final TextStyle? textStyle;

  /// Widget's background color
  final List<Color> backgroundColor;

  /// Editor's palette colors
  final List<Color>? paletteColors;

  /// Editor's default text
  final String text;

  /// Decoration to customize the editor
  final EditorDecoration? decoration;

  final double? minFontSize;
  final double? maxFontSize;

  /// Create a [TextEditor] widget
  ///
  /// [fonts] list of font families that you want to use in editor.
  ///
  /// After edit process completed, [onEditCompleted] callback will be called
  /// with new [textStyle], [textAlingment] and [text] value
  const TextEditor({
    super.key,
    required this.fonts,
    required this.onEditCompleted,
    required this.onChangeBackground,
    this.paletteColors,
    required this.backgroundColor,
    this.text = '',
    this.textStyle,
    this.textAlingment,
    this.minFontSize = 1,
    this.maxFontSize = 100,
    this.onTextAlignChanged,
    this.onTextStyleChanged,
    this.onTextChanged,
    this.decoration,
  });

  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends ConsumerState<TextEditor> {
  late TextStyleModel _textStyleModel;
  late FontOptionModel _fontOptionModel;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool isSaving = false;

  @override
  void initState() {
    _textStyleModel = TextStyleModel(
      widget.text,
      textStyle: widget.textStyle,
      textAlign: widget.textAlingment,
    );
    _fontOptionModel = FontOptionModel(
      _textStyleModel,
      widget.fonts,
      colors: widget.paletteColors,
    );

    // Rebuild whenever a value changes
    _textStyleModel.addListener(() {
      setState(() {});
    });

    // Rebuild whenever a value changes
    _fontOptionModel.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void _editCompleteHandler() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      showCustomSnackBar("Pas de connexion internet");
      return;
    }
    setState(() {
      isSaving = true;
    });
    widget.onEditCompleted(
      _textStyleModel.textStyle!,
      _textStyleModel.textAlign!,
      _textStyleModel.text,
    );

    // Assurez-vous que le widget est construit avant de capturer l'image
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var imageBytes = await _capturePng();
      if (imageBytes != null) {
        await _saveImage(imageBytes);
      }
    });
  }

  void _editBackgroundHandler() {
    widget.onChangeBackground();
  }

  Future<void> _saveImage(Uint8List pngBytes) async {
    try {
      final notifier = ref.watch(infoUserStateNotifier);
      final List<File> fileCapture = [];
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/captured_image.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);
      final files = File(path);
      if (mounted) {
        fileCapture.add(files);
        String message = "Votre story a été créée avec succès.".tr;
        UserModel? myCurrentData = notifier.MydataPersiste;
        ref
            .read(storieStateNotifier.notifier)
            .CreateStory(fileCapture, 'image')
            .then((onValue) async {
          await notificationService.sendNotification(
              myCurrentData!, message, myCurrentData.name.toString());
        });
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      showCustomSnackBar(
          "Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
      return;
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Erreur : $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextEditorData(
      textStyleModel: _textStyleModel,
      fontOptionModel: _fontOptionModel,
      child: Container(
        padding: EdgeInsets.only(right: 10, left: 10, top: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.backgroundColor,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                          child: FaIcon(FontAwesomeIcons.chevronLeft,
                              size: 17, color: Colors.white))),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _editBackgroundHandler,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(100),
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
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      TextAlignment(
                        left: widget.decoration?.alignment?.left,
                        center: widget.decoration?.alignment?.center,
                        right: widget.decoration?.alignment?.right,
                      ),
                      SizedBox(width: 20),
                      FontOptionSwitch(
                        fontFamilySwitch: widget.decoration?.fontFamily,
                        colorPaletteSwitch: widget.decoration?.colorPalette,
                      ),
                      SizedBox(width: 20),
                      TextBackgroundColor(
                        enableWidget: widget.decoration?.textBackground?.enable,
                        disableWidget:
                            widget.decoration?.textBackground?.disable,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _editCompleteHandler,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0), // Arrondir les coins
                          side: BorderSide(
                              color: kPrimaryColor), // Bordure blanche
                        ),
                        backgroundColor: kPrimaryColor, // Fond transparent
                        shadowColor: kPrimaryColor, // Supprime l'ombre
                      ),
                      child: Text(
                        'Partager'.tr,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold), // Couleur du texte blanche
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isSaving == true)
              Expanded(
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Container(
                    padding: EdgeInsets.only(right: 10, left: 10, top: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.backgroundColor,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController()
                          ..text = _textStyleModel.text,
                        onChanged: (value) => _textStyleModel.text = value,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: _textStyleModel.textStyle,
                        textAlign: _textStyleModel.textAlign!,
                        autofocus: false,
                        cursorColor: Colors.white,
                        decoration: null,
                      ),
                    ),
                  ),
                ),
              ),
            if (isSaving == false)
              Expanded(
                child: Row(
                  children: [
                    FontSize(
                      minFontSize: widget.minFontSize!,
                      maxFontSize: widget.maxFontSize!,
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: TextField(
                            controller: TextEditingController()
                              ..text = _textStyleModel.text,
                            onChanged: (value) => _textStyleModel.text = value,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: _textStyleModel.textStyle,
                            textAlign: _textStyleModel.textAlign!,
                            autofocus: false,
                            cursorColor: Colors.white,
                            decoration: null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: _fontOptionModel.status == FontOptionStatus.fontFamily
                  ? FontFamily(_fontOptionModel.fonts)
                  : ColorPalette(_fontOptionModel.colors!),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decoration to customize text alignment widgets' design.
///
/// Pass your custom widget to `left`, `right` and `center` to customize their design
class AlignmentDecoration {
  /// Left alignment widget
  final Widget? left;

  /// Center alignment widget
  final Widget? center;

  /// Right alignment widget
  final Widget? right;

  AlignmentDecoration({this.left, this.center, this.right});
}

/// Decoration to customize text background widgets' design.
///
/// Pass your custom widget to `enable`, and `disable` to customize their design
class TextBackgroundDecoration {
  /// Enabled text background widget
  final Widget? enable;

  /// Disabled text background widget
  final Widget? disable;

  TextBackgroundDecoration({this.enable, this.disable});
}

/// Decoration to customize the editor
///
/// By using this class, you can customize the text editor's design
class EditorDecoration {
  /// Done button widget
  final Widget? doneButton;
  final AlignmentDecoration? alignment;

  /// Text background widget
  final TextBackgroundDecoration? textBackground;

  /// Font family switch widget
  final Widget? fontFamily;

  /// Color palette switch widget
  final Widget? colorPalette;

  EditorDecoration({
    this.doneButton,
    this.alignment,
    this.fontFamily,
    this.colorPalette,
    this.textBackground,
  });
}
