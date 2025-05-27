// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:huawei_push/huawei_push.dart';
import 'package:rxdart/rxdart.dart';
import 'notification_services.dart';

class HMSNotificationServices extends NotificationServices {
  String _token = "";

  static BehaviorSubject<String>? onNotificationClick;

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
    onNotificationClick = BehaviorSubject<String>();

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
      Map<String, dynamic> remoteNotification = {
        "id": remoteMessage["extras"]['id'],
        "title": remoteMessage["extras"]['title'],
        "view": remoteMessage["extras"]['view'],
        "sectionid": remoteMessage["extras"]['sectionid'],
      };
      onNotificationClick?.add(json.encode(remoteNotification));
    }
  }

  static void backgroundMessageCallback(RemoteMessage remoteMessage) async {
    print("backgroundMessageCallback: $remoteMessage");
    String? data = remoteMessage.data;

    Map<String, dynamic> remoteNotification = {
      "id": remoteMessage.dataOfMap?['id'],
      "title": remoteMessage.dataOfMap?['title'],
      "view": remoteMessage.dataOfMap?['view'],
      "sectionid": remoteMessage.dataOfMap?['sectionid'],
    };
    if (data != null) {
      onNotificationClick?.add(json.encode(remoteNotification));
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
      onNotificationClick?.add(json.encode(remoteNotification));
    }
  }

  void _onTokenEvent(Object event) async {
    _token = event.toString();
    if (kDebugMode) {
      log("Huawei MyToken: $_token");
    }
    // await SaveFirebaseNotificationTokenUseCase(injector())(
    //   firebaseNotificationToken: _token,
    // );
  }
}
