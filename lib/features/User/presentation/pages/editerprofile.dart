import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/core/utils/widget/nationaliteListPage.dart';
import 'package:natify/core/utils/widget/paysListPage.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/imageGallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class Editerprofile extends ConsumerStatefulWidget {
  final UserModel myOwnData;
  final String uid;
  const Editerprofile({super.key, required this.myOwnData, required this.uid});

  @override
  ConsumerState<Editerprofile> createState() => _EditerprofileState();
}

class _EditerprofileState extends ConsumerState<Editerprofile> {
  final _formKey = GlobalKey<FormState>();
  final List<File> photoProfile = [];
  var listSituation = [
    "Celibataire",
    "En couple",
    "Fiance(e)",
    "Marie(e)",
    "C'est complique",
    "Separe(e)",
    "Divorce(e)",
    "Veuf/veuve",
  ];
  late List<Map<String, String>> listNationalites =
      Helpers.ListeNationaliteHelper;
  late TextEditingController nameController;
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController paysController;
  late TextEditingController nationaliteController;
  late TextEditingController flagController;
  late TextEditingController ageController;
  late TextEditingController visibiliteAgeController;
  late TextEditingController sexeController;
  late TextEditingController bioController;
  //universite
  late TextEditingController nomUniversiteController;
  late TextEditingController lieuUniversiteController;
  late TextEditingController visibiliteUniversiteController;
  // college
  late TextEditingController nomCollegeController;
  late TextEditingController lieuCollegeController;
  late TextEditingController visibiliteCollegeController;
  // emploi
  late TextEditingController nomEmploiController;
  late TextEditingController visibiliteEmploiController;
  // relation
  late TextEditingController nomRelationController;
  late TextEditingController visibiliteRelationController;
  int _currentLength = 0; // Compteur pour la longueur du texte
  final int _maxLength = 25; // Limite maximale de caractères
  int _currentLengthDesciption = 0; // Compteur pour la longueur du texte
  final int _maxLengthDescription = 150; // Limite maximale de caractères

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: widget.myOwnData.name ?? "");
    firstnameController =
        TextEditingController(text: widget.myOwnData.nom ?? "");
    lastnameController =
        TextEditingController(text: widget.myOwnData.prenom ?? "");
    paysController = TextEditingController(text: widget.myOwnData.pays ?? "");
    nationaliteController =
        TextEditingController(text: widget.myOwnData.nationalite ?? "");
    flagController = TextEditingController(text: widget.myOwnData.flag ?? "");
    ageController = TextEditingController(
        text: widget.myOwnData.age!.isEmpty
            ? ''
            : widget.myOwnData.age![0]['age']);
    visibiliteAgeController = TextEditingController(
        text: widget.myOwnData.age!.isEmpty
            ? 'Public'
            : widget.myOwnData.age?[0]['visibilite'] ?? "");
    sexeController = TextEditingController(text: widget.myOwnData.sexe ?? "");
    bioController = TextEditingController(text: widget.myOwnData.bio ?? "");
    //universite
    nomUniversiteController = TextEditingController(
        text: widget.myOwnData.universite!.isEmpty
            ? ''
            : widget.myOwnData.universite?[0]['nom'] ?? "");
    lieuUniversiteController = TextEditingController(
        text: widget.myOwnData.universite!.isEmpty
            ? ''
            : widget.myOwnData.universite?[0]['lieux'] ?? "");
    visibiliteUniversiteController = TextEditingController(
        text: widget.myOwnData.universite!.isEmpty
            ? 'Public'
            : widget.myOwnData.universite?[0]['visibilite'] ?? "");
    // college
    nomCollegeController = TextEditingController(
        text: widget.myOwnData.college!.isEmpty
            ? ''
            : widget.myOwnData.college?[0]['nom'] ?? "");
    lieuCollegeController = TextEditingController(
        text: widget.myOwnData.college!.isEmpty
            ? ''
            : widget.myOwnData.college?[0]['lieux'] ?? "");
    visibiliteCollegeController = TextEditingController(
        text: widget.myOwnData.college!.isEmpty
            ? 'Public'
            : widget.myOwnData.college?[0]['visibilite'] ?? "");
    // emploi
    nomEmploiController = TextEditingController(
        text: widget.myOwnData.emploi!.isEmpty
            ? ''
            : widget.myOwnData.emploi?[0]['nom'] ?? "");
    visibiliteEmploiController = TextEditingController(
        text: widget.myOwnData.emploi!.isEmpty
            ? 'Public'
            : widget.myOwnData.emploi?[0]['visibilite'] ?? "");
    // relation
    nomRelationController = TextEditingController(
        text: widget.myOwnData.situationamoureux!.isEmpty
            ? "Celibataire"
            : widget.myOwnData.situationamoureux?[0]['situation'] ?? "");
    visibiliteRelationController = TextEditingController(
        text: widget.myOwnData.situationamoureux!.isEmpty
            ? 'Public'
            : widget.myOwnData.situationamoureux?[0]['visibilite'] ?? "");
    setState(() {
      _currentLength = widget.myOwnData.name?.length ?? 0;
      _currentLengthDesciption = widget.myOwnData.bio?.length ?? 0;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    paysController.dispose();
    nationaliteController.dispose();
    flagController.dispose();
    ageController.dispose();
    visibiliteAgeController.dispose();
    sexeController.dispose();
    bioController.dispose();
    //universite
    nomUniversiteController.dispose();
    lieuUniversiteController.dispose();
    visibiliteUniversiteController.dispose();
    // college
    nomCollegeController.dispose();
    lieuCollegeController.dispose();
    visibiliteCollegeController.dispose();
    // emploi
    nomEmploiController.dispose();
    visibiliteEmploiController.dispose();
    // relation
    nomRelationController.dispose();
    visibiliteRelationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void openPaysPage() async {
      final selectedPays = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaysListPage(listPays: listNationalites),
        ),
      );
      if (selectedPays != null) {
        setState(() {
          paysController.text = selectedPays['country'] ?? '';
        });
      }
    }

    void openNationalityPage() async {
      final selectedNationality = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NationaliteListPage(listNationalite: listNationalites),
        ),
      );
      if (selectedNationality != null) {
        setState(() {
          flagController.text = selectedNationality['flagCode'] ?? '';
          nationaliteController.text = selectedNationality['nationality'] ?? '';
        });
      }
    }

    void openPhotoAdd() async {
      final selectedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Imagegallery(),
        ),
      );
      photoProfile.clear();
      if (selectedImage != null) {
        print('le image select est $selectedImage');
        photoProfile.add(selectedImage);
        setState(() {});
      }
    }

    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("edite_profile".tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                    child: FaIcon(FontAwesomeIcons.chevronLeft, size: 20))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  List<Map<String, dynamic>> universite = [];
                  List<Map<String, dynamic>> college = [];
                  List<Map<String, dynamic>> emploi = [];
                  List<Map<String, dynamic>> situation = [];
                  List<Map<String, dynamic>> age = [];
                  if (nomUniversiteController.text != "" &&
                      lieuUniversiteController.text != "") {
                    universite.add({
                      'nom': nomUniversiteController.text.toString(),
                      'lieux': lieuUniversiteController.text.toString(),
                      'visibilite':
                          visibiliteUniversiteController.text.toString()
                    });
                    print('le universite est $universite');
                  }
                  if (nomCollegeController.text != "" &&
                      lieuCollegeController.text != "") {
                    college.add({
                      'nom': nomCollegeController.text.toString(),
                      'lieux': lieuCollegeController.text.toString(),
                      'visibilite': visibiliteCollegeController.text.toString()
                    });
                  }
                  if (nomEmploiController.text != "") {
                    emploi.add({
                      'nom': nomEmploiController.text.toString(),
                      'visibilite': visibiliteEmploiController.text.toString()
                    });
                  }
                  if (nomRelationController.text != "") {
                    situation.add({
                      'situation': nomRelationController.text.toString(),
                      'visibilite': visibiliteRelationController.text.toString()
                    });
                  }
                  if (ageController.text != "") {
                    age.add({
                      'age': ageController.text.toString(),
                      'visibilite': visibiliteAgeController.text.toString()
                    });
                  }
                  if (mounted) {
                    ref.read(infoUserStateNotifier.notifier).updateAllInfoUser(
                        widget.uid,
                        nameController.text,
                        firstnameController.text,
                        lastnameController.text,
                        flagController.text,
                        paysController.text,
                        nationaliteController.text,
                        photoProfile,
                        age,
                        sexeController.text,
                        bioController.text,
                        situation,
                        universite,
                        college,
                        emploi);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Enregistrer".tr,
                style: TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image and Section Header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => openPhotoAdd(),
                            child: photoProfile.isNotEmpty
                                ? Stack(
                                    children: [
                                      ClipOval(
                                        child: SizedBox(
                                            width:
                                                120, // Définir la largeur du cercle
                                            height:
                                                120, // Définir la hauteur du cercle
                                            child: Image.file(
                                              photoProfile
                                                  .first, // Afficher l'image à partir du fichier
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 3,
                                        child: Image.asset(
                                          'assets/ajouter-une-photo.png',
                                          width: 27,
                                          height: 27,
                                        ),
                                      )
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            '${widget.myOwnData.profilePic}',
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: 120.0,
                                          width: 120.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.white),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            Container(
                                          margin: EdgeInsets.only(right: 8.0),
                                          height: 120.0,
                                          width: 120.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/noimage.png'),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.white),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          margin: EdgeInsets.only(right: 8.0),
                                          height: 120.0,
                                          width: 120.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/noimage.png'),
                                              fit: BoxFit.cover,
                                            ),
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 3,
                                        child: Image.asset(
                                          'assets/ajouter-une-photo.png',
                                          width: 27,
                                          height: 27,
                                        ),
                                      )
                                    ],
                                  ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name and Emoji Section with Editable Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            _maxLength), // Limite à 10 caractères
                      ],
                      controller: nameController,
                      validator: (value) {
                        if ((value == null || value.isEmpty)) {
                          return "rempli_champs".tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffix: Text(
                          _currentLength == 0 ? "" : "$_currentLength",
                          style: TextStyle(fontSize: 14),
                        ),
                        labelText: "nom_utilisateur".tr,
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        // Mettre à jour la longueur actuelle
                        setState(() {
                          _currentLength = value.length;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Description Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            _maxLengthDescription), // Limite à 10 caractères
                      ],
                      controller: bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        suffix: Text(
                          _currentLengthDesciption == 0
                              ? ""
                              : "$_currentLengthDesciption",
                          style: TextStyle(fontSize: 14),
                        ),
                        labelText: "description".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.all(15),
                      ),
                      onChanged: (value) {
                        // Mettre à jour la longueur actuelle
                        setState(() {
                          _currentLengthDesciption = value.length;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // SPACE PROFILE Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Info_personnels".tr,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),

                        // Preferred Coin Dropdown
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          items: ['femme', 'homme'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.tr),
                            );
                          }).toList(),
                          value: sexeController.text,
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            sexeController.text = value.toString();
                          },
                          decoration: InputDecoration(
                            labelText: "Genre".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Backup Address
                        TextFormField(
                          controller: firstnameController,
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Nom".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Spirit CryptoKitty
                        TextFormField(
                          controller: lastnameController,
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Prenom".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: ageController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Veuillez entrer votre age".tr;
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null) {
                                    return "Veuillez entrer un age valide".tr;
                                  }
                                  if (age < 14 || age > 90) {
                                    return "agedoit".tr;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Age".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                items: ['Public', 'Moi uniquement']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.tr),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                value: visibiliteAgeController.text,
                                onChanged: (value) {
                                  visibiliteAgeController.text =
                                      value.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: "Visibilite".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Spirit CryptoKitty
                        TextFormField(
                          readOnly: true,
                          onTap: () => openPaysPage(),
                          controller: paysController,
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Pays".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Spirit CryptoKitty
                        TextFormField(
                          readOnly: true,
                          onTap: () => openNationalityPage(),
                          controller: nationaliteController,
                          validator: (value) {
                            if ((value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffix: Text(flagController.text),
                            labelText: "Nationalité".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "education".tr,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                "facultatif".tr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Universite
                        Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: nomUniversiteController,
                                validator: (value) {
                                  if ((lieuUniversiteController.text != "") &&
                                      (value == null || value.isEmpty)) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Nom Universite".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: TextFormField(
                                controller: lieuUniversiteController,
                                validator: (value) {
                                  if ((nomUniversiteController.text != "") &&
                                      (value == null || value.isEmpty)) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Lieux".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          items:
                              ['Public', 'Moi uniquement'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.tr),
                            );
                          }).toList(),
                          value: visibiliteUniversiteController.text,
                          onChanged: (value) {
                            visibiliteUniversiteController.text =
                                value.toString();
                          },
                          validator: (value) {
                            if ((lieuUniversiteController.text != "" ||
                                    nomUniversiteController.text != "") &&
                                (value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Visibilite".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.grey.shade300),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: nomCollegeController,
                                validator: (value) {
                                  if ((lieuCollegeController.text != "") &&
                                      (value == null || value.isEmpty)) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Nom College".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: TextFormField(
                                controller: lieuCollegeController,
                                validator: (value) {
                                  if ((nomCollegeController.text != "") &&
                                      (value == null || value.isEmpty)) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Lieux".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          items:
                              ['Public', 'Moi uniquement'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.tr),
                            );
                          }).toList(),
                          validator: (value) {
                            if ((nomCollegeController.text != "" ||
                                    lieuCollegeController.text != "") &&
                                (value == null || value.isEmpty)) {
                              return "rempli_champs".tr;
                            }
                            return null;
                          },
                          value: visibiliteCollegeController.text,
                          onChanged: (value) {
                            visibiliteCollegeController.text = value.toString();
                          },
                          decoration: InputDecoration(
                            labelText: "Visibilite".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Emploi".tr,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                "facultatif".tr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Backup Address
                        Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                controller: nomEmploiController,
                                decoration: InputDecoration(
                                  labelText: "Nom".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                items: ['Public', 'Moi uniquement']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.tr),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if ((nomEmploiController.text != "") &&
                                      (value == null || value.isEmpty)) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                value: visibiliteEmploiController.text,
                                onChanged: (value) {
                                  visibiliteEmploiController.text =
                                      value.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: "Visibilite".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "relation".tr,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                "facultatif".tr,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Backup Address
                        Row(
                          children: [
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                items: listSituation.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.tr),
                                  );
                                }).toList(),
                                value: nomRelationController.text,
                                onChanged: (value) {
                                  nomRelationController.text = value.toString();
                                },
                                decoration: InputDecoration(
                                  labelText: "situation".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                items: ['Public', 'Moi uniquement']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value.tr),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if ((nomRelationController.text != "") &&
                                      (value == null || value.isEmpty)) {
                                    return "rempli_champs".tr;
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  visibiliteRelationController.text =
                                      value.toString();
                                },
                                value: visibiliteRelationController.text,
                                decoration: InputDecoration(
                                  labelText: "Visibilite".tr,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
