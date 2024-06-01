import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyWebView());
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  // WebViewController 선언
  WebViewController? _webViewController;
  @override
  void initState() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('https://www.joomoonmoa.com')) //출력할 웹페이지
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 5,
        ),
        body: WebViewWidget(controller: _webViewController!),
        // ,
      ),
    );
  }
}
