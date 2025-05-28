import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

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
        backgroundColor: "#000000",
        backgroundUrl: "assets/images/call_background.png",
        actionColor: "#4cAF50",
        textColor: "#FFFFFF",
      ),
      ios: const IOSParams(
        iconName: "CallKitIcon",
        handleType: "generic",
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: "default",
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: "system_ringtone_default",
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}
