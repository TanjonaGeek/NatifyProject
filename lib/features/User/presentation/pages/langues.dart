import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/Services/sharepreference.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/langues/langueController.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class Langues extends StatefulWidget {
  const Langues({super.key});

  @override
  State<Langues> createState() => _LanguesState();
}

class _LanguesState extends State<Langues> {
  var locale = Helpers.locale;
  Future<void> updatelanguage(Locale locale, String nameLangues) async {
  Get.back();
  final languageController = Get.find<LanguageController>();
  await languageController.changeLanguage(locale);

  UserPreferences userPreferences = UserPreferences();
  await userPreferences.saveLanguagePreference(locale);

  // Afficher un message de changement de langue
  // Fluttertoast.showToast(msg: 'Changement langue en $nameLangues', backgroundColor: Colors.black87);
}
  String countryCodeToEmoji(String countryCode) {
  final int firstLetter = countryCode.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
  final int secondLetter = countryCode.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
       appBar: AppBar(
          title: Text('Langues'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: Center(child: FaIcon(FontAwesomeIcons.chevronLeft,size:20))),
              onPressed: () {
                // Action for the back button
                Navigator.pop(context);
              },
            ),
        ),
        body:   Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: Text(
                    "Choisissez la langue qui vous correspond le mieux pour une expérience personnalisée.".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
            ),
            SizedBox(height: 5,),
            Expanded(
              child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context,index){
                           var localeLng = locale[index]['locale'];
                           var charCountry = localeLng.toString().split('_');
                           String emoji = charCountry[1];
                           return Padding(
                                padding: const EdgeInsets.only(left: 5,right: 5,top: 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.all(Radius.circular(8))
                                  ),
                                  child: ListTile(
                                                      onTap: (){
                                                        updatelanguage(localeLng, locale[index]['name']);
                                                      },
                                                      leading: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: kPrimaryColor,
                                  ),
                                  child: Center(child: Text(countryCodeToEmoji(emoji),style: TextStyle(fontSize: 20))),),
                                                      title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(locale[index]['name'].toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold),),
                                  ],
                                    ),
                                     trailing: Icon(Icons.keyboard_arrow_right,color: Colors.grey.shade400,),
                                  ),
                                ),
                              );
                        }, 
                        itemCount: locale.length
                    ),
            ),
          ],
        ),
      ),
    );
  }
}