import 'package:flutter/material.dart';
import 'package:joomoonmoa_flutter/firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

// OS 타입을 정의하는 enum 생성
enum OSType {
  ANDROID,
  iOS,
  WEB,
  MACOS,
  WINDOWS,
  LINUX,
}

extension OSTypeExtension on OSType {
  String get name {
    return toString().split('.').last;
  }
}

// 백그라운드 설정 코드는 맨 최상단에 위치해야함
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

String? token = "test";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await fcmSetting(); // fcmSetting 함수가 완료될 때까지 기다립니다.

  runApp(const MyWebView());
}

Future<void> fcmSetting() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true);

  var initialzationSettingsIOS = const DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initialzationSettingsIOS);
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (message.notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: '@mipmap/ic_launcher',
            color: const Color.fromARGB(0, 122, 90, 248),
          ),
        ),
      );
    }
  });

  // 토큰 발급
  token = await FirebaseMessaging.instance.getToken();
  // 토큰 리프레시 수신
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    // save token to server
    token = newToken;
  });
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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('progressing $progress');
          },
          onPageStarted: (String url) {
            debugPrint(url);
          },
          onPageFinished: (String url) {
            debugPrint('Page Finished');
            // 예시 사용법

            OSType currentOS = OSType.ANDROID;
            // enum 값을 문자열로 변환
            String osName = currentOS.name;
            print(osName); // 출력: ANDROID
            // Page finished loading, now inject the token
            _webViewController!.runJavaScript("""
              (() => { 
                  try {
                    const deviceToken = '$token'; 
                    localStorage.setItem('deviceToken', deviceToken);
                    localStorage.setItem('deviceOs','$osName')
                  } catch(e) {
                    alert(e);
                  }
              })();
            """);
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('https://www.joomoonmoa.com/')); //출력할 웹페이지

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
