import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:jitsi/core/utils/jitsi_services.dart';
import 'package:jitsi/core/utils/send_notification_service.dart';
import 'package:jitsi/presentation/screens/calling/calling_screen.dart';

class JitsiApp extends StatefulWidget {
  const JitsiApp({super.key});

  @override
  State<JitsiApp> createState() => _JitsiAppState();
}

class _JitsiAppState extends State<JitsiApp>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String? token;

  late AnimationController _controller;
  late Animation<double> _fade;

  bool audioMuted = false;
  bool videoMuted = false;
  bool screenShareOn = false;

  JitsiServices jitsiServices = JitsiServices(
    email: "fedo.zaher@example.com",
    avatarUrl: "https://example.com/avatar.jpg",
    displayName: "Fady Zaher",
    room: "roomId",
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _listenToTokenChanges();
    _loadUserDataAndUpdateToken();
    _initCurrentCall();
  }

  @override
  void didUpdateWidget(covariant JitsiApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          debugPrint("actionCallIncoming");
          break;
        case Event.actionCallStart:
          debugPrint("actionCallStart");
          break;
        case Event.actionCallAccept:
          // // TODO: accepted an incoming call
          // // TODO: show screen calling in Flutter
          //   JitsiServices jitsiServices = JitsiServices(
          //     room: roomId,
          //     displayName: displayName,
          //     avatarUrl: avatarUrl,
          //     email: email,
          //   );
          //   await jitsiServices.startMeeting();
          debugPrint("actionCallAcceptNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CallingPage(),
            ),
          );
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

  Future<void> _requestNotificationPermission() async {
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
          "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
          "Notification permission is required, Please allow notification permission from setting."
    });
  }

  Future<dynamic> _initCurrentCall() async {
    await _requestNotificationPermission();
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        debugPrint('DATA: $calls');
        return calls[0];
      } else {
        return null;
      }
    }
  }

  void _listenToTokenChanges() async {
    await FlutterCallkitIncoming.requestFullIntentPermission();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': newToken,
        });
        setState(() {
          token = newToken;
        });
        debugPrint('FCM Token refreshed and updated.');
      }
    });
  }

  Future<void> _loadUserDataAndUpdateToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        name = doc.data()?['name'] ?? '';
        email = doc.data()?['email'] ?? '';
        token = doc.data()?['fcmToken'];
      });

      String? currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken != null && currentToken != token) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': currentToken,
        });
        setState(() {
          token = currentToken;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Stream<QuerySnapshot> _getAllUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff3a7bd5), Color(0xff00d2ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage:
                          NetworkImage("https://example.com/avatar.jpg"),
                    ),
                    title: Text(name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(email),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      onPressed: _logout,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: const Text("FCM Token"),
                      subtitle: Text(token ?? "Loading..."),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      jitsiServices.startMeeting().then((value) async {
                        await SendNotificationService.sendMassageByToken(
                          senderName: "Fady Zaher",
                          receiverName: "Mina Zaher",
                          senderEmail: "fedo.zaher@example.com",
                          receiverEmail: "mina.zaher@example.com",
                          roomId: "roomId",
                          senderMobile: "01273826361",
                          receiverToken:
                              (await FirebaseMessaging.instance.getToken() ??
                                  ""),
                        );
                      });
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text("Start Jitsi Meeting"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: jitsiServices.hangUp,
                    child: const Text("Hang Up"),
                  ),
                  const SizedBox(height: 10),
                  _buildToggle(
                    label: "Audio Muted",
                    value: audioMuted,
                    onChanged: (val) {
                      setState(() => audioMuted = val!);
                      jitsiServices.setAudioMuted(val);
                    },
                  ),
                  _buildToggle(
                    label: "Video Muted",
                    value: videoMuted,
                    onChanged: (val) {
                      setState(() => videoMuted = val!);
                      jitsiServices.setVideoMuted(val);
                    },
                  ),
                  _buildToggle(
                    label: "Screen Share",
                    value: screenShareOn,
                    onChanged: (val) {
                      setState(() => screenShareOn = val!);
                      jitsiServices.toggleScreenShare(val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: jitsiServices.openChat,
                        child: const Text(
                          "Open Chat",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => jitsiServices.sendChatMessage(
                          message: "Hello",
                          participants: ["LdM0k@example.com"],
                        ),
                        child: const Text(
                          "Send Chat Message",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: jitsiServices.closeChat,
                        child: const Text(
                          "Close Chat",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: jitsiServices.retrieveParticipantsInfo,
                        child: const Text(
                          "Get Participants Info",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "All Users",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: _getAllUsersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final users = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: users.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final userData = user.data() as Map<String, dynamic>;
                          final userName = userData['name'] ?? 'Unknown';
                          final userEmail = userData['email'] ?? 'No Email';
                          final userAvatar = userData['avatarUrl'] ??
                              'https://via.placeholder.com/150';

                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(userAvatar),
                              ),
                              title: Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(userEmail),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.video_call,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  jitsiServices
                                      .startMeeting()
                                      .then((value) async {
                                    await SendNotificationService
                                        .sendMassageByToken(
                                      senderName: "Fady Zaher",
                                      receiverName: userName,
                                      senderEmail: "fedo.zaher@example.com",
                                      receiverEmail: userEmail,
                                      roomId: "roomId",
                                      senderMobile: "01273826361",
                                      receiverToken: userData['fcmToken'] ??
                                          (await FirebaseMessaging.instance
                                              .getToken()),
                                    );
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
