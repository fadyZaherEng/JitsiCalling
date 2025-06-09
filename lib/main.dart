import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:jitsi/core/utils/firebase_notification_services.dart';
import 'package:jitsi/core/utils/hms_notification_service.dart';
import 'package:jitsi/presentation/screens/calling/calling_screen.dart';
import 'package:jitsi/presentation/screens/home/home_screen.dart';
import 'package:jitsi/presentation/screens/login/login_screen.dart';
import 'package:jitsi/presentation/screens/register/register_screen.dart';
import 'package:jitsi/presentation/screens/splah/splash_screen.dart';
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
      home: const SplashScreen(),
      // ✅ شاشة البداية
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const JitsiApp(),
        '/calling': (context) => const CallingPage(),
      },
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
