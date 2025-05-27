import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jitsi/core/utils/notification_services.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseNotification {
  FirebaseNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

final didReceiveLocalNotificationSubject =
    BehaviorSubject<FirebaseNotification>();

class FirebaseNotificationService implements NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  static BehaviorSubject<String>? onNotificationClick;

  String get androidNotificationChannelName => "Notification";

  String get androidNotificationChannelId => "Notification";

  @override
  Future<void> initializeNotificationService() async {
    NotificationSettings notificationSettings =
        await _setupNotificationPermission();
    _configMessage();

    String notificationToken = "";

    try {
      notificationToken = await messaging.getToken() ?? "";
    } catch (e) {
      log(e.toString());
    }

    onNotificationClick = BehaviorSubject<String>();

    if (kDebugMode) {
      log("MyToken: $notificationToken");
    }
  }

  // FlutterLocalNotificationsPlugin get _getFlutterLocalNotificationsPlugin =>
  //     FlutterLocalNotificationsPlugin();

  // Future<void> get _getFlutterLocalNotificationsPluginInitializer =>
  //     _getFlutterLocalNotificationsPlugin.initialize(
  //       _getInitializationSettings,
  //       onDidReceiveNotificationResponse: (notificationResponse) {
  //         onNotificationClick?.add(notificationResponse.payload ?? "");
  //       },
  //     );
  //
  // AndroidInitializationSettings get _getAndroidInitializationSettings =>
  //     const AndroidInitializationSettings('@mipmap/ic_notification');
  //
  // final DarwinInitializationSettings _initializationSettingsIOS =
  //     const DarwinInitializationSettings(
  //   requestAlertPermission: true,
  //   requestBadgePermission: true,
  //   requestSoundPermission: true,
  // );
  //
  // InitializationSettings get _getInitializationSettings =>
  //     InitializationSettings(
  //       android: _getAndroidInitializationSettings,
  //       iOS: _initializationSettingsIOS,
  //     );

  Future<NotificationSettings> _setupNotificationPermission() async {
    return await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  //
  // NotificationDetails get _getNotificationDetails => NotificationDetails(
  //       android: _getAndroidNotificationDetails,
  //       iOS: _getIOSNotificationDetails,
  //     );
  //
  // DarwinNotificationDetails get _getIOSNotificationDetails =>
  //     const DarwinNotificationDetails(
  //       presentAlert: true,
  //       presentBadge: true,
  //       presentSound: true,
  //       presentBanner: true,
  //       presentList: true,
  //       sound: 'default',
  //     );
  //
  // AndroidNotificationDetails get _getAndroidNotificationDetails =>
  //     AndroidNotificationDetails(
  //       androidNotificationChannelId,
  //       androidNotificationChannelName,
  //       importance: Importance.max,
  //       priority: Priority.max,
  //       playSound: true,
  //       channelShowBadge: true,
  //       enableLights: true,
  //       autoCancel: true,
  //       enableVibration: true,
  //       channelAction: AndroidNotificationChannelAction.createIfNotExists,
  //       icon: '@mipmap/ic_notification',
  //     );
  //
  // void _showNotificationAsLocal({
  //   String? title,
  //   String? message,
  //   Map<String, dynamic>? data,
  // }) async {
  //   await _getFlutterLocalNotificationsPluginInitializer.whenComplete(
  //     () async {
  //       await _getFlutterLocalNotificationsPlugin.show(
  //         0,
  //         title,
  //         message,
  //         _getNotificationDetails,
  //         payload: json.encode(data),
  //       );
  //     },
  //   );
  // }

  void _setNotificationMessage(RemoteMessage message) {
    // _showNotificationAsLocal(
    //   data: message.data,
    //   message: message.notification?.body,
    //   title: message.notification?.title,
    // );
  }

  void _configMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.notification?.body}");
      _setNotificationMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint("Notification opened: ${message.notification?.body}");
      _setNotificationMessage(message);
      _handleNotificationClick(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("App launched (terminated): ${message.notification?.body}");
        _setNotificationMessage(message);
        _handleNotificationClick(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageCallback);
  }

  void _handleNotificationClick(RemoteMessage message) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    if (message.notification?.body != null && data["view"] == "general") {
      data["body"] = message.notification!.body;
    }
    onNotificationClick?.add(json.encode(data));
  }

  Future<void> _backgroundMessageCallback(RemoteMessage message) async {
    debugPrint("Background message received: ${message.notification?.body}");
    _setNotificationMessage(message);
    _handleNotificationClick(message);
  }
}
