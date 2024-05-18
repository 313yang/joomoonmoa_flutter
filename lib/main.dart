import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void getToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("token:::$fcmToken");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the message when the app is in the foreground
      print('Message received: ${message.messageId}');
      getToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: WebViewWidget(controller: _webViewController!),
      ),
    );
  }
}
