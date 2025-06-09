import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:jitsi/core/utils/jitsi_services.dart';
import 'package:jitsi/presentation/screens/calling/calling_screen.dart';

class CallKitConfig {
  final String nameCaller;
  final String appName;
  final String avatar;
  final String handle;
  final String textAccept;
  final String textDecline;
  final int type;
  final int duration;
  final NotificationParams missedCallNotificationParams;
  final Map<String, String> extra;
  final Map<String, String> headers;

  CallKitConfig({
    required this.nameCaller,
    required this.appName,
    required this.avatar,
    required this.handle,
    required this.textAccept,
    required this.textDecline,
    required this.type,
    required this.duration,
    required this.missedCallNotificationParams,
    required this.extra,
    required this.headers,
  });

  Future<void> showIncomingCall({
    required String roomId,
  }) async {
    CallKitParams callKitParams = CallKitParams(
      nameCaller: nameCaller,
      appName: appName,
      avatar: avatar,
      handle: handle,
      textAccept: textAccept,
      textDecline: textDecline,
      type: type,
      duration: duration,
      extra: extra,
      headers: headers,
      callingNotification: missedCallNotificationParams,
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: "system_ringtone_default",
          logoUrl: 'assets/images/logo.png',
          backgroundColor: '#0955fa',
          backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call",
          isShowCallID: false),
      ios: const IOSParams(
        iconName: "CallKitIcon",
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  Future<void> callKitEventListener({
    required String roomId,
    required String displayName,
    required String avatarUrl,
    required String email,
  }) async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          debugPrint("actionCallIncoming");
          break;
        case Event.actionCallStart:
          debugPrint("actionCallStart");
          break;
        case Event.actionCallAccept:
          // TODO: accepted an incoming call
          // TODO: show screen calling in Flutter
          JitsiServices jitsiServices = JitsiServices(
            room: roomId,
            displayName: displayName,
            avatarUrl: avatarUrl,
            email: email,
          );
          await jitsiServices.startMeeting();
          break;
        case Event.actionCallDecline:
          debugPrint("actionCallDecline");
          break;
        case Event.actionCallEnded:
          debugPrint("actionCallEnded");
          break;
        case Event.actionCallTimeout:
          debugPrint("actionCallTimeout");
          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          debugPrint("actionCallCallback");
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          debugPrint("actionCallToggleHold");
          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS
          debugPrint("actionCallToggleMute");
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          debugPrint("actionCallToggleDmtf");
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          debugPrint("actionCallToggleGroup");
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          debugPrint("actionCallToggleAudioSession");
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          debugPrint("actionDidUpdateDevicePushTokenVoip");
          break;
        case Event.actionCallCustom:
          // TODO: for custom action
          debugPrint("actionCallCustom");
          break;
        default:
          debugPrint("actionCallCustom");
          break;
      }
    });
  }
}
