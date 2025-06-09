import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:jitsi/core/utils/call_kit_config.dart';
import 'package:jitsi/core/utils/notification_services.dart';

class FirebaseNotificationService implements NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  Future<void> initializeNotificationService() async {
    await _setupNotificationPermission();
    _configMessage();

    String notificationToken = "";

    try {
      notificationToken = await messaging.getToken() ?? "";
    } catch (e) {
      log(e.toString());
    }

    if (kDebugMode) {
      log("MyToken: $notificationToken");
    }
  }

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

  void _configMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.data}");
      _gitsiCallHandler(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint("Notification opened: ${message.data}");
      _gitsiCallHandler(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("App launched (terminated): ${message.data}");
        _gitsiCallHandler(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageCallback);
  }

  Future<void> _backgroundMessageCallback(RemoteMessage message) async {
    debugPrint("Background message received: ${message.data}");
    _gitsiCallHandler(message);
  }

  void _gitsiCallHandler(RemoteMessage event) {
    try{
    if (event.data.containsKey("room_id")) {
      CallKitConfig callKitConfig = CallKitConfig(
        nameCaller: event.data["sender_name"]??"",
        appName: "Jitsi",
        avatar: event.data["sender_image"]??"",
        handle: event.data["sender_mobile"]??"",
        textAccept: "Accept",
        textDecline: "Decline",
        missedCallNotificationParams: const NotificationParams(
          isShowCallback: true,
          showNotification: true,
          subtitle: "Missed Call",
          callbackText: "Call Back",
        ),
        duration: 30000,
        extra: {
          'room_id': event.data["room_id"]??"",
        },
        headers: {
          'api_key': "YOUR_API_KEY",
          "platform": "flutter",
        },
        type: 0,
      );
      callKitConfig.showIncomingCall(roomId: event.data["room_id"]);
      ///add listener to user accept or reject call
      callKitConfig.callKitEventListener(
        displayName: event.data["receiver_name"]??"",
        email: event.data["receiver_email"]??"",
        avatarUrl: event.data["receiver_image"]??"",
        roomId: event.data["room_id"]??"",
      );
    } else {
      //TODO Handle Notification
    }
    }catch(e){
      debugPrint("FFFFFFFFFFFFFFFFFFFFFFFFFFF${e.toString()}");
    }
  }
}
