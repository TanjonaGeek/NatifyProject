import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:natify/core/Services/LocationService.dart';
import 'package:natify/core/Services/globalFocusService.dart';
import 'package:natify/core/utils/colors.dart';
import 'package:natify/core/utils/slideNavigation.dart';
import 'package:natify/features/Chat/presentation/pages/AllMessagePage.dart';
import 'package:natify/features/Storie/presentation/pages/AllStoriePage.dart';
import 'package:natify/features/Storie/presentation/pages/creeateStoriePage.dart';
import 'package:natify/features/User/presentation/pages/UserProfilePage.dart';
import 'package:natify/features/User/presentation/pages/createannoncemarket.dart';
import 'package:natify/features/User/presentation/pages/editerprofile.dart';
import 'package:natify/features/User/presentation/pages/map/maps.dart';
import 'package:natify/features/User/presentation/pages/notification/listNotification.dart';
import 'package:natify/features/User/presentation/provider/state/info_state_user.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:natify/features/User/presentation/widget/list/SearchProduct.dart';
import 'package:natify/features/User/presentation/widget/list/filterListOfProduct.dart';
import 'package:natify/features/User/presentation/widget/list/listVenteMarketplace.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int index;
  const HomeScreen({super.key, required this.index});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final ValueNotifier<int> _selectedIndexNotifier =
      ValueNotifier<int>(0); // Déclare ValueNotifier pour l'index sélectionné
  final String uidUser = auth.currentUser?.uid ?? "";
  final String names = auth.currentUser?.displayName ?? "";
  final String photos = auth.currentUser?.photoURL ?? "";
  final LocationService _locationService = LocationService();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print('le status est resumed');
      ref.read(infoUserStateNotifier.notifier).updateStatusUser(true, uidUser);
    }
    // LoginToZego(ref);
    // }else if(state == AppLifecycleState.inactive){
    //   print('le status est inactive');
    //     ref.read(infoUserStateNotifier.notifier).updateStatusUser(false,uidUser);
    //     // LoginToZego(ref);
    // }
    else if (state == AppLifecycleState.paused) {
      print('le status est paused');
      ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
    } else if (state == AppLifecycleState.detached) {
      print('le status est detached');
      ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
      // LoginToZego(ref);
    } else if (state == AppLifecycleState.hidden) {
      print('le status est hidden');
      ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
      // ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
      // LoginToZego(ref);
    } else if (state == AppLifecycleState.inactive) {
      print('le status est inactive');
      ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
      // ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
      // LoginToZego(ref);
    } else {
      ref.read(infoUserStateNotifier.notifier).updateStatusUser(false, uidUser);
      print('le status est inactive');
    }
  }

  Future<void> _updateLocationOnce() async {
    try {
      await _locationService.updateUserLocation(context);
    } catch (e) {}
  }

  Future<void> updateOnlineUsers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Récupérer tous les utilisateurs avec isOnline == true
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .get();

    // Parcourir chaque document et mettre à jour isOnline à false
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isOnline': false});
    }

    print("Mise à jour terminée !");
  }

  @override
  void initState() {
    super.initState();
    // updateOnlineUsers();
    _updateLocationOnce();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  // Liste des titres pour chaque page
  final List<String> appBarTitles = [
    'Discussion',
    'Decouvert',
    'Stories',
    'Marketplaces'
  ];

  void _onItemTapped(
    int index,
  ) {
    if (index == 4) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(uid: uidUser),
        ),
      );
    } else if (index == 1) {
      final notifier = ref.watch(infoUserStateNotifier);
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => Maps(
            statusShareDistance: notifier.MydataPersiste!.hiddenPosition,
            photoUrl: notifier.MydataPersiste!.profilePic.toString(),
          ),
        ),
      );
    } else {
      // if (index == 1) {
      //   ref.read(allUserListStateNotifier.notifier).ResetFilter();
      // }
      _selectedIndexNotifier.value = index; // Met à jour l'index sélectionné
    }
  }

  Stream<int> getUnreadNotificationsCount() {
    return firestore
        .collection('users')
        .doc(uidUser)
        .collection('Notification')
        .where('statusOnSee', isEqualTo: false)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return 0; // Retourne 0 si le snapshot est null ou vide
      }
      return querySnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;
    final notifier = ref.read(infoUserStateNotifier);
    return ThemeSwitchingArea(
      child: Scaffold(
          // backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            // backgroundColor: Colors.white,
            title: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return selectedIndex == 3
                      ? SizedBox(
                          width: 90,
                          height: 90,
                          child: Image.asset(
                            'assets/gomarket.png',
                          ))
                      : Text(
                          appBarTitles[selectedIndex].tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                },
              ),
            ),
            actions: [
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return selectedIndex == 2
                      ? InkWell(
                          onTap: () {
                            SlideNavigation.slideToPage(context, GalleryPage());
                          },
                          child: FaIcon(
                            FontAwesomeIcons.squarePlus,
                            size: 24,
                          ))
                      : SizedBox();
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return selectedIndex == 3
                      ? Row(
                          children: [
                            InkWell(
                              onTap: () {
                                SlideNavigation.slideToPage(
                                    context, CreateAnnonceMarket());
                              },
                              child: FaIcon(
                                FontAwesomeIcons.plus,
                                size: 22,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                SlideNavigation.slideToPage(
                                    context, FilterProductPage());
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.sliders,
                                size: 22,
                              ),
                            ),
                          ],
                        )
                      : IconButton(
                          iconSize: 50,
                          icon: Stack(
                            children: [
                              InkWell(
                                  onTap: () {
                                    SlideNavigation.slideToPage(
                                        context, AllNotification());
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.bell,
                                    size: 24,
                                  )),
                              Positioned(
                                  bottom: 10,
                                  left: 0,
                                  child: StreamBuilder<int>(
                                    stream: getUnreadNotificationsCount(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                          child: Center(
                                              child: FittedBox(
                                                  child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              '0',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ))),
                                        ); // Affiche un indicateur de chargement
                                      } else if (snapshot.hasError) {
                                        return Text(
                                            ''); // Affiche une erreur si elle se produit
                                      } else {
                                        int unreadCount = snapshot.data ??
                                            0; // Définit à 0 si aucune donnée n'est reçue
                                        return Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                          ),
                                          child: Center(
                                              child: FittedBox(
                                                  child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              '$unreadCount',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ))),
                                        );
                                      }
                                    },
                                  ))
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => AllNotification()),
                            );
                          },
                        );
                },
              ),
            ],
            leading: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.penToSquare,
                size: 24,
              ),
              onPressed: () {
                final notifier = ref.watch(infoUserStateNotifier);
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                      builder: (context) => Editerprofile(
                            uid: uidUser,
                            myOwnData: notifier.MydataPersiste!,
                          )),
                );
              },
            ),
          ),
          body: AnimatedBottomNavBar(
            notifier: notifier,
            selectedIndexNotifier:
                _selectedIndexNotifier, // Transmet l'index sélectionné
            onItemTapped:
                _onItemTapped, // Transmet la fonction de changement d'index
          )),
    );
  }
}

class AnimatedBottomNavBar extends ConsumerStatefulWidget {
  final ValueNotifier<int> selectedIndexNotifier;
  final ValueChanged<int> onItemTapped;
  final InfoStateUser notifier;

  const AnimatedBottomNavBar({
    super.key,
    required this.selectedIndexNotifier,
    required this.onItemTapped,
    required this.notifier,
  });
  @override
  _AnimatedBottomNavBarState createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends ConsumerState<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  final List<Widget> _pages = [
    KeepAlivePage(child: Allmessagepage()),
    Container(),
    KeepAlivePage(child: Allstoriepage()),
    //  AllUserList(),
    MarketplacePage()
  ];

  late final StreamSubscription<bool> _keyboardSubscription;
  final ValueNotifier<bool> _isKeyboardVisibleNotifier = ValueNotifier(false);
  final globalFocusManager = GlobalFocusManager();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(globalFocusManager);
    var keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      _isKeyboardVisibleNotifier.value = visible;
    });
  }

  @override
  void dispose() {
    // Annulez la souscription pour libérer les ressources
    _keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: widget.selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            return IndexedStack(
              index: selectedIndex,
              children: _pages,
            );
          },
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
            valueListenable: _isKeyboardVisibleNotifier,
            builder: (context, isKeyboardVisible, _) {
              return isKeyboardVisible
                  ? SizedBox.shrink()
                  : ValueListenableBuilder<int>(
                      valueListenable: widget.selectedIndexNotifier,
                      builder: (context, selectedIndex, _) {
                        return BottomNavigationBar(
                          currentIndex: selectedIndex,
                          onTap: (index) {
                            globalFocusManager.unfocusAll();
                            if (index == 0) {
                              widget.selectedIndexNotifier.value = index;
                            } else if (index == 2) {
                              widget.selectedIndexNotifier.value = index;
                            }
                            widget.onItemTapped(index);
                          },
                          type: BottomNavigationBarType.fixed,
                          // backgroundColor: Colors.white,
                          items: <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                              icon: AnimatedBottomIcon(
                                isProfile: '',
                                icon: FontAwesomeIcons.solidComments,
                                label: "Discussion".tr,
                                isSelected: selectedIndex ==
                                    0, // Vérifie si c'est sélectionné
                              ),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: AnimatedBottomIcon(
                                isProfile: '',
                                icon: FontAwesomeIcons.search,
                                label: "Decouvert".tr,
                                isSelected: selectedIndex ==
                                    1, // Vérifie si c'est sélectionné
                              ),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: AnimatedBottomIcon(
                                isProfile: '',
                                icon: FontAwesomeIcons.solidNewspaper,
                                label: "Stories".tr,
                                isSelected: selectedIndex ==
                                    2, // Vérifie si c'est sélectionné
                              ),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: AnimatedBottomIcon(
                                isProfile: '',
                                icon: FontAwesomeIcons.shopify,
                                label: "Marketplaces".tr,
                                isSelected: selectedIndex ==
                                    3, // Vérifie si c'est sélectionné
                              ),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: AnimatedBottomIcon(
                                isProfile: widget
                                    .notifier.MydataPersiste!.profilePic
                                    .toString(),
                                icon: FontAwesomeIcons.solidUserCircle,
                                label: "Profile".tr,
                                isSelected: selectedIndex ==
                                    4, // Vérifie si c'est sélectionné
                              ),
                              label: '',
                            ),
                          ],
                        );
                      },
                    );
            }));
  }
}

class AnimatedBottomIcon extends StatelessWidget {
  final IconData icon;
  final String isProfile;
  final String label;
  final bool isSelected;

  const AnimatedBottomIcon({
    super.key,
    required this.icon,
    required this.isProfile,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isSelected ? 30 : 24, // Animation pour agrandir l'icône
            child: isProfile.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: isProfile.toString(),
                      placeholder: (context, url) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: isSelected ? 25 : 23,
                            height: isSelected ? 25 : 23,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: isSelected ? 25 : 23,
                      height: isSelected ? 25 : 23,
                      fit: BoxFit.cover,
                    ),
                  )
                : FaIcon(
                    icon,
                    color: isSelected ? kPrimaryColor : Colors.grey,
                    size: isSelected
                        ? 25
                        : 23, // Animation de la taille de l'icône
                  ),
          ),
          SizedBox(
            height: 4,
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isSelected ? 16 : 14, // Animation de la taille du texte
              color: isSelected ? kPrimaryColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
            ),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
