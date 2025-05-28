import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jitsi/core/utils/jitsi_services.dart';
import 'package:jitsi/core/utils/send_notification_service.dart';

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
  }

  void _listenToTokenChanges() {
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
                    await SendNotificationService.sendMassageByToken(
                      senderName: "Fady Zaher",
                      receiverName: "Mina Zaher",
                      senderEmail: "fedo.zaher@example.com",
                      receiverEmail: "mina.zaher@example.com",
                      roomId: "roomId",
                      senderMobile: "01273826361",
                    );
                    jitsiServices.startMeeting();
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text("Start Jitsi Meeting"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
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
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
