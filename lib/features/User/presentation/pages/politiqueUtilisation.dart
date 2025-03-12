import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class PolitiqueUtilisation extends StatefulWidget {
  const PolitiqueUtilisation({super.key});

  @override
  State<PolitiqueUtilisation> createState() => _PolitiqueUtilisationState();
}

class _PolitiqueUtilisationState extends State<PolitiqueUtilisation> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );

    // Charger le fichier HTML local
    _loadLocalHtml();
  }

  void _loadLocalHtml() async {
    String fileText = await rootBundle
        .loadString("assets/condition_utilisateur/acceptable_use.html");

    // Ajout du meta viewport pour un meilleur affichage mobile
    String htmlContent = '''
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
      <style>
        body { font-size: 18px; padding: 15px; line-height: 1.6; }
      </style>
    </head>
    <body>
      $fileText
    </body>
    </html>
    ''';

    _controller.loadRequest(Uri.dataFromString(
      htmlContent,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ));
  }

  void _reloadWebView() {
    _loadLocalHtml(); // Recharge le HTML local
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Politique d'utilisation acceptable de Natify".tr,
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadWebView, // Recharger le HTML local
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
