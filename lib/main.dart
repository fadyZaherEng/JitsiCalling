import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:jitsi/core/utils/firebase_notification_services.dart';
import 'package:jitsi/core/utils/hms_notification_service.dart';
import 'package:jitsi/core/utils/jitsi_services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebaseService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Jitsi",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const JitsiApp(),
    );
  }
}

class JitsiApp extends StatefulWidget {
  const JitsiApp({super.key});

  @override
  State<JitsiApp> createState() => _JitsiAppState();
}

class _JitsiAppState extends State<JitsiApp> {
  JitsiServices jitsiServices = JitsiServices(
    email: "fedo.zaher@example.com",
    avatarUrl: "https://example.com/avatar.jpg",
    displayName: "Fady Zaher",
    room: "roomId",
  );
  bool audioMuted = false;
  bool videoMuted = false;
  bool screenShareOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jitsi Meetings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: jitsiServices.startMeeting,
                child: const Text("Join"),
              ),
              TextButton(
                onPressed: jitsiServices.hangUp,
                child: const Text("Hang Up"),
              ),
              Row(
                children: [
                  const Text("Set Audio Muted"),
                  Checkbox(
                    value: audioMuted,
                    onChanged: jitsiServices.setAudioMuted,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("Set Video Muted"),
                  Checkbox(
                    value: videoMuted,
                    onChanged: jitsiServices.setVideoMuted,
                  ),
                ],
              ),
              TextButton(
                onPressed: () => jitsiServices.sendEndpointTextMessage(
                  message: "Hey Endpoint",
                  participants: ["LdM0k@example.com"],
                ),
                child: const Text("Send Hey Endpoint Message To All"),
              ),
              Row(
                children: [
                  const Text("Toggle Screen Share"),
                  Checkbox(
                    value: screenShareOn,
                    onChanged: jitsiServices.toggleScreenShare,
                  ),
                ],
              ),
              TextButton(
                onPressed: jitsiServices.openChat,
                child: const Text("Open Chat"),
              ),
              TextButton(
                onPressed: () => jitsiServices.sendChatMessage(
                  message: "Hello",
                  participants: ["LdM0k@example.com"],
                ),
                child: const Text("Send Chat Message to All"),
              ),
              TextButton(
                onPressed: jitsiServices.closeChat,
                child: const Text("Close Chat"),
              ),
              TextButton(
                onPressed: jitsiServices.retrieveParticipantsInfo,
                child: const Text("Retrieve Participants Info"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> initFirebaseService() async {
  if (!kIsWeb) {
    try {
      if (Platform.isIOS) {
        await _initializeFirebaseServices();
      } else {
        final int resultCode =
            await HmsApiAvailability().isHMSAvailableWithApkVersion(28);
        if (resultCode == 1) {
          await _initializeFirebaseServices();
        } else {
          await _initializeHuaweiServices();
        }
      }
    } catch (e) {}
  }
}

Future<void> _initializeFirebaseServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseNotificationService().initializeNotificationService();
  } catch (e) {}
}

Future<void> _initializeHuaweiServices() async {
  await HMSNotificationServices().initializeNotificationService();
}
