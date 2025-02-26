import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/core/utils/snack_bar_helpers.dart';
import 'package:natify/core/utils/widget/nationaliteListPage.dart';
import 'package:natify/core/utils/widget/paysListPage.dart';
import 'package:natify/features/HomeScreen.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
class Isfillnationalitepage extends ConsumerStatefulWidget {
  const Isfillnationalitepage({super.key});

  @override
  _IsfillnationalitepageState createState() => _IsfillnationalitepageState();
}

class _IsfillnationalitepageState extends  ConsumerState<Isfillnationalitepage> {
  final List<Map<String, String>> listNationalitesAndPays = Helpers.ListeNationaliteHelper;
  String Nationalite= "";
  String Pays= "";
  String flag = "";
   void _openNationalityPage() async {
    final selectedNationality = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NationaliteListPage(listNationalite: listNationalitesAndPays),
      ),
    );
    if (selectedNationality != null) {
      setState(() {
        flag = selectedNationality['flagCode'] ?? '';
        Nationalite = selectedNationality['nationality'] ?? '';
      });
    }
  }
  void _openPaysPage() async {
   final selectedPays = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaysListPage(listPays: listNationalitesAndPays),
      ),
    );
    if (selectedPays != null) {
      setState(() {
        Pays = selectedPays['country'] ?? '';
      });
    }
  }
  Future<void> navigateToNextStep()async{
    try {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
       showCustomSnackBar("Pas de connexion internet");
       return ;
    }
    if(Pays.isEmpty || Nationalite.isEmpty){
       showCustomSnackBar("Veuillez ajouter les informations. Merci de les fournir pour continuer.");
                  }else{
                    if(mounted){
                      ref.read(infoUserStateNotifier.notifier).updateInfoUser(FirebaseAuth.instance.currentUser!.uid, 'nationalite', Nationalite,flag);
                    }
                    if(mounted){
                      ref.read(infoUserStateNotifier.notifier).updateInfoUser(FirebaseAuth.instance.currentUser!.uid, 'pays',Pays,'');
                    }
                    SlideNavigation.slideToPagePushRemplacement(context,HomeScreen(index: 0,));
      }
    } catch (e) {
       showCustomSnackBar("Une erreur s'est produite. Veuillez vérifier votre connexion et réessayer.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Origines et Résidence'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
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
           actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextButton(
                onPressed: navigateToNextStep,
                child: Text('OK'.tr, style: TextStyle(fontSize: 17,color: kPrimaryColor,fontWeight: FontWeight.bold)),
                )
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
              child: Text(
                textAlign: TextAlign.center,
                'Renseignez votre nationalité et votre pays de résidence pour une expérience plus personnalisée.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: SmallCard(
                    onTap: _openNationalityPage,
                    flag: flag,
                    contenue: Nationalite,
                    titre: 'Nationalité',description: 'Le Nationalité dont vous détenez la citoyenneté.',)
                ),
                SizedBox(width: 9),
                 Flexible(
                  child: SmallCard(
                    onTap: _openPaysPage,
                    flag: '',
                    contenue: Pays,
                    titre:'Pays',description: 'Le pays où vous vivez en ce moment.',)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class SmallCard extends StatelessWidget {
  final String titre;
  final String description;
  final VoidCallback onTap;
  final String contenue;
  final String flag;
  const SmallCard({super.key, required this.titre, required this.description, required this.onTap, required this.contenue, required this.flag});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre.tr,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description.tr,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black,width: 1), // Black border
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                ),
                child: Text(
                  contenue == "" ? "Fournir Info".tr : "$flag $contenue",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black, // Black text
                  ),
                ),
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
