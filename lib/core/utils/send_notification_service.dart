// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class SendNotificationService {
  static Future<void> sendMassageByToken({
    String projectId = "948576209897",
    required String senderName,
    required String receiverName,
    String senderImage =
        "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4",
    String receiverImage =
        "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4",
    required String senderEmail,
    required String receiverEmail,
    required String roomId,
    required String senderMobile,
    required String receiverToken,
  }) async {
    final String serverAccessToken = await getServerAccessToken();
    print('Access Token: $serverAccessToken');
    String url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    // const currentFCMToken =
    //     "dfM1vCj3S_yShAyA2ghFOi:APA91bFrX7VfBK29A5zNbS76myv967nASi2TGvovDDN9REmNAmDBslnYBYKkcorMUx-wDx2zRi7-BHrOoYa_DFjOB7v4_o07OzfATAbZ8AekbldF2YOwmbc";
    // await FirebaseMessaging.instance.getToken();
    final Map<String, dynamic> massage = {
      "message": {
        "token": receiverToken,
        "notification": {
          "title": "you have a new message on request ",
          "body": "message",
        },
        'data': {
          "sender_name": senderName,
          "receiver_name": receiverName,
          "sender_image": senderImage,
          "receiver_image": receiverImage,
          "sender_email": senderEmail,
          "receiver_email": receiverEmail,
          "room_id": roomId,
          "sender_mobile": senderMobile,
          'current_user_fcm_token': receiverToken,
        }
      }
    };
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $serverAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(massage),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  static Future<void> sendMassageByTopic({
    String projectId = "948576209897",
    required String requestId,
    required String topic,
    required String message,
    required int unitId,
    required BuildContext context,
    bool isUserAdded = false,
  }) async {
    // TODO: Get the access token
    final String serverAccessToken = await getServerAccessToken();
    print('Access Token: $serverAccessToken');

    String url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final Map<String, dynamic> notificationMessage = {
      "message": {
        "topic": "topic$requestId", // Specify the topic instead of the token
        "notification": {
          "title": "you have a new message on request $requestId",
          "body": message,
        },
        "data": {
          "view": "support_comments",
          "id": requestId,
          "sectionid": unitId.toString(),
          "request_id": requestId,
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $serverAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notificationMessage),
    );

    if (response.statusCode == 200) {
      if (!isUserAdded) {
        print('Notification sent successfully');
      }
    } else {
      if (!isUserAdded) {
        print('Notification sent Failed');
      }
      print('Failed to send notification');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  static Future<String> getServerAccessToken() async {
    // Path to your Service Account JSON key file
    const serviceAccountJson = {
      "type": "service_account",
      "project_id": "zegoapp-3db9a",
      "private_key_id": "96bf1c975e25bee49b9c53398d357155d873cfb8",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCQCDe8ohdsl0uM\nC39xqT9WGZx0FI1vZioS/I4mod+VnzhnkV+V+tx6w+GY9+onxZB6g8GIV2M5pQHt\nBYaY0bah9nBdTIQrBV4a2fV7i1kDGeRQssRlj69v0eJEtI99Yd6ctFlLreKgIV56\nu9k3MbhhHQjZh2rI2AHqexpvz+oCIsliiItIjO/ADcA1BL/s6IZ3NXeDnac43twL\n3lr5fSJesjBVyfBdS0zYdHpj5GwV1zXWYR+qadYCFvskf4Km/UjnYW+6d3p4R16W\n4geMlTr3x1pY1urB2uXpZCLuKgf13q0DVHcs7v1eK99Zoqm5iV8A4OGXHOBFxm+9\nYTP9BuxLAgMBAAECggEABiD7Y/ZO4k5vX895qamN28kfipUx+KHTkUi0sOsl4oNK\nqt7gd/5ilUkybLn76ynjYdCO6BFD4njlhz/XquHWgilEdqhT0BrVbCBN3Tx1kulf\n+SdU51Pkn2KJXM5MHs0AuZ8axr5ahYu9Eb7srs1LbxCwKnAkHCqMdIt16yNS0Y5G\nC2vMBW8Mwuz5+/MWb/YMTN1upPo8eoMwVYEGIXuyTw9Elju74ASmsQr1lbpif/Lx\nOHeY2nzLeXQJRuspmkaCEWeSeQIhgDNNSYw6LQJNRwXVjMDDsvOO9i4dXNSjoZhH\nm85oni2zCO31dNQIxQSrbXF4YapCaJ0uzjX8f0+DNQKBgQDEctORn4N446VXzEkG\n3PPOZnLeJg18KPvKpkJAzj7Qc1twyokMMfb9RA1A+timZ+UojMDXywSHa6krg6Ez\n8ZhiFMoKCpgvC3mq2FrzaSLL2zXl7cFaRldAJWgACV39icAiiaQ9O/V22HlC0A16\nRwMRCUXn9vblW6xC7nreIqrs9wKBgQC7savBOqNLld1Poq1Lol7YLrYBrVOR71gr\nua9ADOT6gPfZ2/8RKbm+eYNK6UvOXAaj1HEfgmKkqqOO548DHP5h5X/KctuPh4O5\nWPjNJX/M0rtQL4d+34KNzgEa01rtpHnxcyn9C6dfNJgvHOzNjhCJkyLrQxPSowbS\nu7PRJYQKTQKBgCA7eu08z/SI3XsvYJgIrtQhyR0b/0Bs9QtGBj7d2D6Zftpd0Oi4\nVf8uKEKOJff/ugDSP13oyKBzkLk8CrocHNWS9ad6H4gwiND4WMvxZy0tlYVZYk0u\nl2hF+u9umgZckLLaBKGrcdYDJLpKqrtyZVVpQRgTVGVDilsdB/nklEj3AoGATyC3\nJQ5Ae4Qhugn9/w3j6EXBC3Hz8mkyBbURcfI9snIei2UY4jZyDSATPsid4dCgJ/9O\n9Za1WXBq5bsvaoOVptXnCwVjFN5vpPsiYPI3L7WDrGltOQqncnrvskx6YAdgNW90\nuy5nkFaO9gW+u2XyCN3T8dTkjX+XR85EH58uTF0CgYAwN08auUfkpbR8l9N3EsAk\n8as/7QJnO5dTPifpuFtB3XFHzMaPDkyHd/PuapXYshHG+iavmDCEEiObb8Sf4s0Z\nraeF6WidSg7o8FM1iEXyufkNJqzC/aV6K/EYhtg+ZPgFhh5yrA+j4SOIWVg255q9\nMv5bAaL0sPU/j6ALcFb2cg==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-kl8iu@zegoapp-3db9a.iam.gserviceaccount.com",
      "client_id": "100908717387784242576",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-kl8iu%40zegoapp-3db9a.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );
    client.close();
    return credentials.accessToken.data;
  }

  static Future subscribeToGroup(String requestId, String userId) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('topic$requestId');
      print("Subscribed to topic: $requestId");
    } catch (e) {
      print("Error subscribing to topic: $e");
    }
    // Save subscription info to Firestore
    // FirebaseFirestore.instance.collection('subscriptions').doc(requestId).set({
    //   'userId': userId,
    //   'requestId': requestId,
    //   'timestamp': FieldValue.serverTimestamp(),
    // });
  }

  static Future unsubscribeFromGroup(String requestId) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('topic$requestId');
      print("Unsubscribed from topic: $requestId");
    } catch (e) {
      print("Error unsubscribing from topic: $e");
    }
  }
}
