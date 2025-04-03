import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/User/presentation/widget/list/filterListOfProduct.dart';
import 'package:natify/features/User/presentation/widget/list/listProductByfiltre.dart';

class SearchProduct extends ConsumerStatefulWidget {
  const SearchProduct({super.key});

  @override
  ConsumerState<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends ConsumerState<SearchProduct> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool loadingLocation = false;
  // Fonction pour récupérer les suggestions basées sur ce que l'utilisateur tape
  void _getSuggestions(String query) async {
    Future.delayed(Duration(milliseconds: 500), () {});
    setState(() {
      loadingLocation = true;
      _suggestions = [];
    });
    Future.delayed(Duration(seconds: 1), () {});
    try {
      if (query.isNotEmpty) {
        // Requête Firestore pour rechercher dans la collection `suggestions`
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('suggestions')
            .where('term', isGreaterThanOrEqualTo: query)
            .where('term',
                isLessThanOrEqualTo: query + '\uf8ff') // Recherche par préfixe
            .limit(15) // Limiter les suggestions à 5
            .get();

        List<Map<String, dynamic>> suggestions = querySnapshot.docs.map((doc) {
          return {
            'term': doc['term'],
            'category': doc['category'], // Inclure aussi la catégorie
          };
        }).toList();

        setState(() {
          _suggestions = suggestions;
          loadingLocation = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          loadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        loadingLocation = false;
      });
    }
  }

  Future<void> findTerm(String term) async {
    if (mounted) {
      ref.read(marketPlaceUserStateNotifier.notifier).SetNameSearchTerm(term);
    }
    Future.delayed(Duration(seconds: 1), () {});
    SlideNavigation.slideToPage(context, MarketplaceResultFiltrePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              suffix: loadingLocation == true
                  ? Container(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    )
                  : SizedBox.shrink(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2.0,
                ),
              ),
              contentPadding:
                  EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 3),
              hintText: 'Rechercher'.tr,
              hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            controller: _searchController,
            onChanged: (query) {
              // Obtenir les suggestions à chaque changement de texte
              _getSuggestions(query);
            },
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: Center(
                child: FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 20,
            )),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              SlideNavigation.slideToPage(context, FilterProductPage());
            },
            icon: FaIcon(
              FontAwesomeIcons.sliders,
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage des suggestions
          _suggestions.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      var suggestion = _suggestions[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion['term'],
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 1,
                              ),
                              Text(
                                "${suggestion['category']}".tr,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          // Lorsque l'utilisateur clique sur une suggestion, faire la recherche pour ce terme
                          _searchController.text = suggestion['term'];
                          String term = suggestion['term'];
                          findTerm(term);
                        },
                      );
                    },
                  ),
                )
              : Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: Image.asset(
                            'assets/marketplace (1).png',
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.center,
                          "Aucun_produit_disponible.".tr,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        // SizedBox(height: 4),
                        // Text(
                        //   textAlign: TextAlign.center,
                        //   "Actuellement_aucun_produit".tr,
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.w400, fontSize: 17),
                        // ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
