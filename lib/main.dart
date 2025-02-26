import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/config/routes/routes.dart';
import 'package:natify/config/themes/themeColors.dart';
import 'package:natify/core/Services/NotificationService.dart';
import 'package:natify/core/Services/sharepreference.dart';
import 'package:natify/core/utils/langues/langueController.dart';
import 'package:natify/core/utils/langues/localStringLanguage.dart';
import 'package:natify/features/User/presentation/pages/auth/AuthUserPage.dart';
import 'package:natify/features/User/presentation/provider/user_provider.dart';
import 'package:natify/features/checking.dart';
import 'package:natify/injector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:chat_application/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final languageController = Get.put(LanguageController(), permanent: true);
  await initializeLanguage(languageController);
  await initializationDepencies();
  if (kIsWeb) {
    // Initialisation pour le Web
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? "",
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? "",
        databaseURL: dotenv.env['FIREBASE_DATABASE_URL'] ?? "",
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? "",
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? "",
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? "",
        appId: dotenv.env['FIREBASE_APP_ID'] ?? "",
      ),
    );
  } else {
    // Initialisation pour Mobile (Android/iOS)
    await Firebase.initializeApp();
  }

  runApp(ProviderScope(child: MyApp(languageController: languageController)));
}

// Future<void> initializeLanguage(LanguageController languageController) async {
//   UserPreferences userPreferences = UserPreferences();
//   Locale? savedLocale = await userPreferences.getLanguagePreference();
//   languageController.currentLocale.value = savedLocale ?? Locale('en', 'US');
// }

Future<void> initializeLanguage(LanguageController languageController) async {
  UserPreferences userPreferences = UserPreferences();
  Locale? savedLocale = await userPreferences.getLanguagePreference();

  if (savedLocale != null) {
    print('le mande ato ambony ato $savedLocale');
    // Si une langue est sauvegardée, applique-la
    languageController.currentLocale.value = savedLocale;
  } else {
    // Sinon, récupère la langue du téléphone
    Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    // Liste des langues supportées
    List<String> supportedLanguages = [
      'en',
      'fr',
      'es',
      'de',
      'pt',
      'ar',
      'pl',
      'tr',
      'it'
    ]; // Ajoute les langues que tu veux
    if (supportedLanguages.contains(systemLocale.languageCode)) {
      String defaultCountry = {
            'fr': 'FR',
            'en': 'US',
            'de': 'DE',
            'es': 'ES',
            'pt': 'PT',
            'ar': 'AR',
            'pl': 'PL',
            'tr': 'TR',
            'it': 'IT',
          }[systemLocale.languageCode] ??
          systemLocale.countryCode ??
          '';
      // Si la langue du téléphone est supportée
      languageController.currentLocale.value = Locale(
        systemLocale.languageCode,
        defaultCountry,
      );
    } else {
      // Sinon, appliquer la langue anglaise par défaut
      languageController.currentLocale.value = Locale('en', 'US');
    }
  }
  // Met à jour la langue dans l'application
  Get.updateLocale(languageController.currentLocale.value);
}

class MyApp extends ConsumerStatefulWidget {
  final LanguageController languageController;
  const MyApp({super.key, required this.languageController});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final notificationService = GetIt.instance<NotificationService>();
  @override
  void initState() {
    super.initState();
    // ref.read(infoUserStateNotifier.notifier).saveVersionApp('inconnu');
    notificationService.requestPermissionNotification();
    notificationService.FirebaseInit(context);
    notificationService.setupInteractMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(userAuthStateNotifier);
    final isPlatformDark =
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? darkTheme : lightTheme;
    return OKToast(
      child: ThemeProvider(
          initTheme: initTheme,
          builder: (context, myTheme) {
            return Consumer(
              builder: (context, ref, child) {
                return Obx(() => GetMaterialApp(
                      theme: myTheme,
                      initialRoute: kIsWeb
                          ? '/admin/dashboard'
                          : '/', // Redirige vers admin sur le web
                      translations: localStringLanguage(),
                      locale: widget.languageController.currentLocale.value,
                      onGenerateRoute: Routes.generateRoute,
                      fallbackLocale: Locale('en', 'US'),
                      debugShowCheckedModeBanner: false,
                      // home: AdminPanel(route: "/admin/dashboard" ,body: Dashboard()),
                      home: StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.userChanges(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.data == null) {
                                if (FirebaseAuth.instance.currentUser == null &&
                                    !authNotifier.isLogout) {
                                  return AuthUserPage();
                                }
                              }
                            }
                            return Cheking();
                          }),
                    ));
              },
            );
          }),
    );
  }
}
