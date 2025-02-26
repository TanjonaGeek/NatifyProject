import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:natify/features/User/data/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class NotificationService {
  FirebaseMessaging message = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  void requestPermissionNotification() async {
    NotificationSettings settings = await message.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      sound: true,
      provisional: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('notification permission authorized');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('notification permission provisional');
    } else {
      AppSettings.openAppSettings();
      print('notification permission denied');
    }
  }

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    await _flutterLocalNotificationPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload) {
        HandleMessage(context, message);
      },
    );
  }

  void FirebaseInit(BuildContext context) async {
    clearNotificationsOnStartup().then((onValue) {
      FirebaseMessaging.onMessage.listen((message) {
        print('le title est ${message.notification!.title.toString()}');
        print('le body est ${message.notification!.body.toString()}');
        if (Platform.isAndroid) {
          initLocalNotification(context, message);
          showNotification(message);
        } else {
          showNotification(message);
        }
      });
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    print('mande am notification');
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High importance Notification',
        importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  Future<String?> getDeviceToken() async {
    String? token = await message.getToken();
    return token;
  }

  void RefreshToken() async {
    message.onTokenRefresh.listen((event) {
      print('le token refresh est ${event.toString()}');
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      HandleMessage2(context, initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      HandleMessage(context, event);
    });
  }

  void HandleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msg') {
      String uid = message.data['type'];
      String name = message.data['name'];
      // Future(()=>Get.to(MobileChatScreen(uid: uid,name:name)));
    }
  }

  void HandleMessage2(BuildContext context, RemoteMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (message.data['type'] == 'msg') {
      String uid = message.data['type'];
      // Future(()=>Get.to(ChatsScreen(prefs:prefs)));
    }
  }

  void createNotification(int count, int i, int id, String title) {
    //show the notifications.
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: count,
        progress: i);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    _flutterLocalNotificationPlugin.show(
        id, title, 'importation $i%', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> clearNotificationsOnStartup() async {
    await _flutterLocalNotificationPlugin.cancelAll();
  }

  Future<String> getAccessToken() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/credentials/service_account_key.json');
      final serviceAccountJson = json.decode(jsonString);

      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;

      client.close();
      return accessToken;
    } catch (e) {
      print('le erreur de path $e');
      rethrow;
    }
  }

  Future<void> sendNotification(
      UserModel user, String mesg, String nameSender) async {
    try {
      // Obtenir l'access token
      final accessToken = await getAccessToken();

      final body = {
        'message': {
          'token': user.tokenNotification,
          'notification': {
            'title': nameSender,
            'body': mesg,
          },
          'data': {
            'type': 'msg',
            'id_user': user.uid,
          },
        },
      };

      var response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/chatapplication-a9d74/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'Bearer $accessToken', // Utilisation de l'access token
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification : $e');
    }
  }

  /// Envoie des notifications à plusieurs utilisateurs par lots
  Future<void> sendNotificationForAll(
      UserModel user, String mesg, String title, List<String> tokens) async {
    const int batchSize =
        100; // Taille du lot d'envoi (envoyer 100 notifications en parallèle)
    List<Future<void>> futures = [];

    for (int i = 0; i < tokens.length; i += batchSize) {
      // Diviser les tokens en lots
      final batchTokens = tokens.sublist(
          i, i + batchSize < tokens.length ? i + batchSize : tokens.length);

      // Envoyer les notifications pour chaque token dans le lot
      for (var token in batchTokens) {
        futures.add(sendNotificationForUser(user, mesg, title, token));
      }

      // Attendre la fin de l'envoi des notifications dans ce lot
      await Future.wait(futures);
      print(
          "Notifications envoyées pour le lot d'abonnés: ${batchTokens.length} utilisateurs.");
    }

    print("Toutes les notifications envoyées.");
  }

  /// Envoie une notification à un utilisateur
  Future<void> sendNotificationForUser(
      UserModel user, String mesg, String title, String token) async {
    try {
      // Obtenir l'access token
      final accessToken = await getAccessToken();

      final body = {
        'message': {
          'token':
              token, // Envoi d'une notification à un utilisateur spécifique
          'notification': {
            'title': title,
            'body': mesg,
          },
          'data': {
            'type': 'msg',
            'id_user': user.uid,
          },
        },
      };

      var response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/chatapplication-a9d74/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'Bearer $accessToken', // Utilisation de l'access token
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Notification envoyée avec succès à $token.");
      } else {
        print(
            "Erreur lors de l'envoi de la notification à $token : ${response.body}");
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification : $e');
    }
  }
}
