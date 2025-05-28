// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:jitsi/core/utils/call_kit_config.dart';
import 'notification_services.dart';

class HMSNotificationServices extends NotificationServices {
  String _token = "";

  @override
  Future<void> initializeNotificationService() async {
    await Push.setAutoInitEnabled(true);

    bool isEnabled = await Push.isAutoInitEnabled();

    Push.enableLogger();
    Push.turnOnPush();

    Push.getToken("");
    Push.getTokenStream.listen(
      _onTokenEvent,
      onError: (error) {
        log("hms Error getting token: $error");
      },
    );

    Push.onNotificationOpenedApp.listen(_onNotificationOpenedApp);

    var initialNotification = await Push.getInitialNotification();
    _onNotificationOpenedApp(initialNotification);

    Push.onMessageReceivedStream.listen(
      _onMessageReceived,
    );

    await Push.registerBackgroundMessageHandler(
      backgroundMessageCallback,
    );
  }

  void _onNotificationOpenedApp(dynamic remoteMessage) {
    print("onNotificationOpenedApp: $remoteMessage");
    if (remoteMessage != null) {
      _gitsiCallHandler(remoteMessage);
    }
  }

  void backgroundMessageCallback(RemoteMessage remoteMessage) async {
    print("backgroundMessageCallback: $remoteMessage");
    String? data = remoteMessage.data;

    Map<String, dynamic> remoteNotification = {
      "id": remoteMessage.dataOfMap?['id'],
      "title": remoteMessage.dataOfMap?['title'],
      "view": remoteMessage.dataOfMap?['view'],
      "sectionid": remoteMessage.dataOfMap?['sectionid'],
    };
    if (data != null) {
      _gitsiCallHandler(remoteMessage);
    }
  }

  void _onMessageReceived(RemoteMessage remoteMessage) {
    print("onMessageReceived: $remoteMessage");
    String? data = remoteMessage.data;
    Map<String, dynamic> remoteNotification = {
      "id": remoteMessage.dataOfMap?['id'],
      "title": remoteMessage.dataOfMap?['title'],
      "view": remoteMessage.dataOfMap?['view'],
      "sectionid": remoteMessage.dataOfMap?['sectionid'],
    };
    if (data != null) {
      _gitsiCallHandler(remoteMessage);
    }
  }

  void _onTokenEvent(Object event) async {
    _token = event.toString();
    if (kDebugMode) {
      log("Huawei MyToken: $_token");
    }
  }

  void _gitsiCallHandler(RemoteMessage event) {
    if (event.dataOfMap != null && event.dataOfMap!.containsKey("room_id")) {
      CallKitConfig callKitConfig = CallKitConfig(
        nameCaller: event.dataOfMap!["sender_name"]!,
        appName: "Jitsi",
        avatar: event.dataOfMap!["sender_image"]!,
        handle: event.dataOfMap!["sender_mobile"]!,
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
          'user_id': event.dataOfMap!["sender_id"]!,
        },
        headers: {
          'api_key': "YOUR_API_KEY",
          "platform": "flutter",
        },
        type: 0,
      );
      callKitConfig.showIncomingCall(roomId: event.dataOfMap!["room_id"]!);
    } else {
      //TODO Handle Notification
    }
  }
}
