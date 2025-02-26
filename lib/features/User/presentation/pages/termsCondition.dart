import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TermeCondition extends StatefulWidget {
  const TermeCondition({super.key});

  @override
  State<TermeCondition> createState() => _TermeConditionState();
}

class _TermeConditionState extends State<TermeCondition> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur WebView
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
      )
      ..loadRequest(Uri.parse("https://app.getterms.io/view/DIMpv/tos/en-au"));
  }

  void _reloadWebView() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Conditions d'utilisation".tr,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadWebView,
            ),
          ],
        ),
        body: _isLoading 
        ? 
        Center(
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
          ),
        )
        : Stack(
          children: [
            WebViewWidget(controller: _controller),
          ],
        ),
      ),
    );
  }
}
