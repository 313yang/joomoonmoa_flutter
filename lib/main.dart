import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Future _dailyAtTimeNotification() async {
//   const notiTitle = 'title';
//   const notiDesc = 'description';

//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   final result = await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );

//   var android = const AndroidNotificationDetails('id', notiTitle, notiDesc,
//       importance: Importance.max, priority: Priority.max);
//   // var ios = IOSNotificationDetails();
//   var detail = NotificationDetails(android: android);

//   if (result) {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.deleteNotificationChannelGroup('id');

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0, // id는 unique해야합니다. int값
//       notiTitle,
//       notiDesc,
//       detail,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
// }

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initAndroid() async {
  // Android용 새 Notification Channel
  // const AndroidNotificationChannel androidNotificationChannel =
  //     AndroidNotificationChannel(
  //   'high_importance_channel', // 임의의 id
  //   'High Importance Notifications', // 설정에 보일 채널명
  //   importance: Importance.max,
  // );

  // Notification Channel을 디바이스에 생성
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(androidNotificationChannel);
}

/// E/flutter (24168): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: PlatformException(error, Attempt to invoke virtual method 'int java.lang.Integer.intValue()' on a null object reference, null, java.lang.NullPointerException: Attempt to invoke virtual method 'int java.lang.Integer.intValue()' on a null object reference
void getToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("token:::$fcmToken");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  final notification = message.notification;
  if (message.notification != null) {
    try {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            importance: Importance.high,
            icon: "@mipmap/ic_launcher",
          ),
        ),
      );
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
      print('Background;:Message received: ${message.notification?.title}');
      print('Background;:Message received: ${message.notification?.body}');
    } catch (e) {
      print(e);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FirebaseMessaging.instance.requestPermission(
  //   alert: true,
  //   announcement: true,
  //   badge: true,
  //   carPlay: true,
  //   criticalAlert: true,
  //   provisional: true,
  //   sound: true,
  // );

  _initNotiSetting();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // print('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyWebView());
}

void _initNotiSetting() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // final initSettingsIOS = IOSInitializationSettings(
  //   requestSoundPermission: false,
  //   requestBadgePermission: false,
  //   requestAlertPermission: false,
  // );
  const initSettings = InitializationSettings(
    android: initSettingsAndroid,
    // iOS: initSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
  );
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  // WebViewController 선언
  WebViewController? _webViewController;
  var token = "";
  @override
  void initState() {
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('https://www.joomoonmoa.com')) //출력할 웹페이지
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    // initAndroid();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the message when the app is in the foreground
      print('Message received: ${message.notification?.title}');
      print('Message received: ${message.notification?.body}');
    });
    getToken();
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
