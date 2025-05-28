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
  }) async {
    final String serverAccessToken = await getServerAccessToken();
    print('Access Token: $serverAccessToken');
    String url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    // final currentFCMToken = await FirebaseMessaging.instance.getToken();
    final Map<String, dynamic> massage = {
      "message": {
        "token":
            "dLy4_mHYRG6Awf6h-UWuYN:APA91bHoyc6lPUiqoLxyag20zvLECMtf2E0otsR_zC3bvYQwm8mhDSpRZp2ZXlA1Ou3gt8Dij5GaNy8RmHB2UmUQknuIIxU_AyP2oSjFgK-p8150pbMbCEE",
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
          'current_user_fcm_token':
              "dLy4_mHYRG6Awf6h-UWuYN:APA91bHoyc6lPUiqoLxyag20zvLECMtf2E0otsR_zC3bvYQwm8mhDSpRZp2ZXlA1Ou3gt8Dij5GaNy8RmHB2UmUQknuIIxU_AyP2oSjFgK-p8150pbMbCEE",
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
      "private_key_id": "90a5073d06c5e14521b4f02a882fa5ad33e2d1ca",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCzPKHZb1q6IQdF\n0tZfUj+K8mbqfJMYHy1Dqn5yIly125xj4YyX7umBpqdUBGcPoUnUyoGgxFcw5roF\n7HpozE7uCBD9AYcsHd3ENMTeAoplUlT/HZaq9uRp8ZVFsRQ5oL0s665Gtc5z/bFW\nA/8tiM2IEP6iZ8I4iVRrAyO4tEFP9s28xh3XlHYmkBcjjPYwstCMnzg/M8uZfcpQ\njbvB+r6MzXL8pA5z5wUKUVLqFjqaBuEx8HE0J2YWsI5ynHayTn6p8kbBB8s9TJdI\nXiwifSCx42eyQwk3sVdmk7ENmWU2NPyWgbaUDfNx+C0/c9aRZgtL9W26NfqBA5Hi\nO6l0dE5NAgMBAAECggEAU/Oj2WzjYYgD2IwTFe23zpSQaOd1nFhKAsYyWLJIm3Ok\nMlJcYHOqkqwk9uDjBvqkUtORWORt9H01h33Grhx4IdzMXD0he6P3kiWnSleFTET+\ng8nvnt9qiEb8BHsXPpDP2uD/LaaNb13V+LSBiunnXwKayiXwXjvQuxjq2+IuL03h\nUEiqyvbPh2w0W9Jtv5rTi6DnmWfSiOxxxYzExuOTUC9ixNHLpAb2tG4BoKCo1pPz\nQa6uEtBHGtTvS5OTZnR0wkGRLDt3PMzDydus3neS9hy65aWq55tDIUvDwmCmHObG\nHy4ReRYfc/NO2vFWUNnAXsbd0XNV4PjA5pfwkWAJjwKBgQDWmt8/DNTeuWgBaqmH\nEgBebHPr8SnLYRcvQEDMhos/mXZvXPj6qfQ39yzYYMWt49/hzTto49M7ImZ7L6Pl\nII1m8ilW/n/hKBxcVxtu9qta/oAUjyIDuYGATs1tONyUL/kvilEf4+yZ1YxZVr/y\nJn7JbxahZT83R9SwkyrKzIN8jwKBgQDVz0sAGpeKQ65l0y9v/Kl82dUYzfVaK5/h\nmMrHLewZDcM7DDeqEmyBNqWl1+jt01ShN1CLjk+OffLQ1fBKqjQNxnOlm+eFZ04s\nWd/WHkSSvDW16wCPBmb1pirofTaJ8t+3w9qM+rLy1xJ9frYxHcolSmolSOhXKcQc\nrBWPOuotYwKBgE21aM9Y4x//PQT+TYLGZvHKDbPK8NpfPtjySESHF5chB7zNiq6h\nqfg1/bwgVpRf5mrKORADJzLLgxZqKsvGHM3BNGz23PF358UcGaf1lBjv/Qr0xVlZ\n6+W9Iy/AnkbelDm9uSB2FO+jXx3ehsS1YcWo/yXUFq76yK5jq+QhaB9LAoGBALPx\nRfnMZ4Vh+MCRv/bL+gite/7oN3mwBVrkMKT5LR7YylpDqgVkhBUrXLX6xHqDxVH5\nL7yEBMizj0vbAeSU4kJFpsbWMz++9be13ABkcOndpIZ6RXoZtUVAmBQabXAkC8yo\n9KJ5y2k9QL6FiehEXgCMZFEEzyWsbPSEj5B/0N5pAoGBAKNgBG4xDtnws7IqSzeC\n3hQYTybWcLdQTvTlGRNuB9/4PaCfmraTE4eWJvaHDMzI2P+LRo8Yr4+80hsSdcvn\nWkcVhyO6YZR6d7Jc5npc5XUJZO/mKHJydfhcd6Ofw5xBdiuN3Ltdj9knJrzzyfiu\nCYgsFBAJoYFfm/LgWsEfvaIE\n-----END PRIVATE KEY-----\n",
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
