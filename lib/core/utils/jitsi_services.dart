import 'package:flutter/cupertino.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiServices {
  final JitsiMeet jitsiMeet = JitsiMeet();
  late JitsiMeetConferenceOptions? options;
  late JitsiMeetEventListener? eventListener;
  late String roomId;
  List<String> participants = [];

  JitsiServices({
    required String room,
    required String displayName,
    required String avatarUrl,
    required String email,
  }) {
    eventListener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        debugPrint("conferenceJoined: url: $url");
      },
      conferenceTerminated: (url, error) {
        debugPrint("conferenceTerminated: url: $url, error: $error");
      },
      conferenceWillJoin: (url) {
        debugPrint("conferenceWillJoin: url: $url");
      },
      participantJoined: (email, name, role, participantId) {
        debugPrint(
          "participantJoined: email: $email, name: $name, role: $role, "
          "participantId: $participantId",
        );
        participants.add(participantId!);
      },
      participantLeft: (participantId) {
        debugPrint("participantLeft: participantId: $participantId");
      },
      audioMutedChanged: (muted) {
        debugPrint("audioMutedChanged: isMuted: $muted");
      },
      videoMutedChanged: (muted) {
        debugPrint("videoMutedChanged: isMuted: $muted");
      },
      endpointTextMessageReceived: (senderId, message) {
        debugPrint(
            "endpointTextMessageReceived: senderId: $senderId, message: $message",);
      },
      screenShareToggled: (participantId, sharing) {
        debugPrint(
          "screenShareToggled: participantId: $participantId, "
          "isSharing: $sharing",
        );
      },
      chatMessageReceived: (senderId, message, isPrivate, timestamp) {
        debugPrint(
          "chatMessageReceived: senderId: $senderId, message: $message, "
          "isPrivate: $isPrivate, timestamp: $timestamp",
        );
      },
      chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
      participantsInfoRetrieved: (participantsInfo) {
        debugPrint(
          "participantsInfoRetrieved: participantsInfo: $participantsInfo, ",
        );
      },
      readyToClose: () {
        closeMeeting();
      },
    );

    options = JitsiMeetConferenceOptions(
      room: room,
      serverURL: 'https://meet.ffmuc.net/',
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
        // "disableDeepLinking": true,
        // "disableThirdPartyRequests": true,
        // "audioQuality": {"opusMaxAverageBitrate": 32000},
        "subject": "Jitsi Meet Flutter SDK",
      },
      featureFlags: {
        // "video_share.enabled": false,
        // "security_options.enabled": false,
        // "meeting_password.enabled": false,
        // "prejoinpage.enabled": false,
        // "replace_participants": false,
        // "lobby_mode.enabled": false,
        // "unsaveroomwarning.enabled": false,
        // "raise_hand.enabled": false,
        // "invite.enabled": false,
        // "car-mode.enabled": false,
        // "add-people.enabled": false,
        // "speakerstats.enabled": false,
        FeatureFlags.addPeopleEnabled: true,
        FeatureFlags.welcomePageEnabled: true,
        FeatureFlags.preJoinPageEnabled: true,
        FeatureFlags.unsafeRoomWarningEnabled: true,
        FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
        FeatureFlags.audioFocusDisabled: true,
        FeatureFlags.audioMuteButtonEnabled: true,
        FeatureFlags.audioOnlyButtonEnabled: true,
        FeatureFlags.calenderEnabled: true,
        FeatureFlags.callIntegrationEnabled: true,
        FeatureFlags.carModeEnabled: true,
        FeatureFlags.closeCaptionsEnabled: true,
        FeatureFlags.conferenceTimerEnabled: true,
        FeatureFlags.chatEnabled: true,
        FeatureFlags.filmstripEnabled: true,
        FeatureFlags.fullScreenEnabled: true,
        FeatureFlags.helpButtonEnabled: true,
        FeatureFlags.inviteEnabled: true,
        FeatureFlags.androidScreenSharingEnabled: true,
        FeatureFlags.speakerStatsEnabled: true,
        FeatureFlags.kickOutEnabled: true,
        FeatureFlags.liveStreamingEnabled: true,
        FeatureFlags.lobbyModeEnabled: true,
        FeatureFlags.meetingNameEnabled: true,
        FeatureFlags.meetingPasswordEnabled: true,
        FeatureFlags.notificationEnabled: true,
        FeatureFlags.overflowMenuEnabled: true,
        FeatureFlags.pipEnabled: true,
        FeatureFlags.pipWhileScreenSharingEnabled: true,
        FeatureFlags.preJoinPageHideDisplayName: true,
        FeatureFlags.raiseHandEnabled: true,
        FeatureFlags.reactionsEnabled: true,
        FeatureFlags.recordingEnabled: true,
        FeatureFlags.replaceParticipant: true,
        FeatureFlags.securityOptionEnabled: true,
        FeatureFlags.serverUrlChangeEnabled: true,
        FeatureFlags.settingsEnabled: true,
        FeatureFlags.tileViewEnabled: true,
        FeatureFlags.videoMuteEnabled: true,
        FeatureFlags.videoShareEnabled: true,
        FeatureFlags.toolboxEnabled: true,
        FeatureFlags.iosRecordingEnabled: true,
        FeatureFlags.iosScreenSharingEnabled: true,
        FeatureFlags.toolboxAlwaysVisible: true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        avatar: avatarUrl.isEmpty
            ? "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4"
            : avatarUrl,
        email: email,
      ),
    );
  }

  //start meeting
  Future<void> startMeeting() async {
    try {
      await jitsiMeet.join(options!, eventListener!);
      debugPrint("startMeeting");
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

  //end meeting
  Future<void> closeMeeting() async {
    try {
      await jitsiMeet.closeChat();
      //MainService
      debugPrint("closeMeeting");
      //call update status
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

  void hangUp() async {
    await jitsiMeet.hangUp();
    debugPrint("hangUp");
  }

  Future<bool> setAudioMuted(bool? muted) async {
    var a = await jitsiMeet.setAudioMuted(muted!);
    debugPrint("$a");
    return muted;
  }

  Future<bool> setVideoMuted(bool? muted) async {
    var a = await jitsiMeet.setVideoMuted(muted!);
    debugPrint("$a");
    return muted;
  }

  void sendEndpointTextMessage({
    required List<String> participants,
    required String message,
  }) async {
    var a = await jitsiMeet.sendEndpointTextMessage(message: message);
    debugPrint("$a");

    for (var p in participants) {
      var b = await jitsiMeet.sendEndpointTextMessage(to: p, message: message);
      debugPrint("$b");
    }
  }

  Future<bool> toggleScreenShare(bool? enabled) async {
    await jitsiMeet.toggleScreenShare(enabled!);
    return enabled;
  }

  void openChat() async {
    await jitsiMeet.openChat();

    debugPrint("openChat");
  }

  void sendChatMessage({
    required List<String> participants,
    required String message,
  }) async {
    var a = await jitsiMeet.sendChatMessage(message: message);
    debugPrint("$a");

    for (var p in participants) {
      a = await jitsiMeet.sendChatMessage(to: p, message: message);
      debugPrint("$a");
    }
  }

  void closeChat() async {
    await jitsiMeet.closeChat();
    debugPrint("closeChat");
  }

  void retrieveParticipantsInfo() async {
    var a = await jitsiMeet.retrieveParticipantsInfo();
    debugPrint("$a");
  }
}
