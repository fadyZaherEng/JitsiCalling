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

    const currentFCMToken =
        "cCdkdzK6Te6yuBVjVvU5qK:APA91bHDILFQoXLCwdpnQyrAWdeVslcXhE26xDNKi2_OAdhO-0TANmzoSfhjMc4PGKLl-iFv9xDPJHL5Krue7_TIfyEiQyhdT5ZZxBCrGTeKGY58EexsHhw";
    // await FirebaseMessaging.instance.getToken();
    final Map<String, dynamic> massage = {
      "message": {
        "token": currentFCMToken,
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
          'current_user_fcm_token': currentFCMToken,
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
      "private_key_id": "077b22d03eefc8b055867117bf27e9ed8952a5ae",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDhZpzCZdvdQiPK\nFB44N3khL8mzNaFOUQPh0vTvsXMvmHpAIXjw+XF5ObRcdbXeE6a/P3r3HMrErHnV\n0GUcZpprdaN/UFhqg5IrT79O11oFwzMWHaqzQxZU4ONOr81o/eBMOmoJkLQFTu82\nMPKo3ikkmrho9WZNmO+vUeT7LfFxcXGbPJ5H7xBtzy3mx5ZsUnPfm3VG2r3huMMm\nVBLzlalxnbtcg3DUC0vbsKYv0JBO7OqLiYEBHBXDgAEmvrDbIfSpHkr8bS+1qdv3\nEERlnCI/ep/y8manpKX16kmvFCLTmLE+QWAgpBerFuuc17/jhEmlDnmByMkYKxE7\nL72JCszNAgMBAAECggEADucG5D9xyu4tiZXM7bCVPKF5N3ULRi9LD2owMYzM7c+p\n/YV5Bo2nd/lduGM79APemXRr/9ySd3Bj2cQee0M5YHN1rNw2DEzIpD5wipjoZcsj\nHIo3mASOfGwl+zTaYt+uLbwK+LjtfhBa9n1D/fA6TiZAnQfkjKrY5gGHHyhJd1OG\nB7JQGAcBhZ+NHSTBUTEF2NG5RaPgbS0+QTBiT6aXNFS/r73myS9ciCg9XHltINb5\nuQD0r7kqcGNYI7hJUBlzFpSoAFgPdWF0CBAy2Xa4fEBUPWhaI7qhN56SyeBnCbnF\nOYSKS3Y+GYfNzME8wDOEAxcjn8OZ7FdZjkBDz/CE7QKBgQD0GitNOc9KxqG/i+yi\n2ZmL0YP8W+pvLNUGMUn7QuZd2LdpBqoFOpAqlvnLogE2uJWkimHIubq5dIGjEHwg\n+iYbIUUdmH9zI3KuGcL9EZdhU3pqYFvowVQEbLeQHdQ0QmMWiXwgAycy+WrLXZ7E\nZd3dAUsy5fqs+fF6L+A6irXpkwKBgQDsYxfT9aiSgqkpx4OK8Wjoazq9E4TVliCv\nSKk6fLLoZ3OGea1Qed0aj8LgLv8rmy3xOU0yH6+xaYi0hPQZkzAB8MrJP0tkdGJ2\nJlAepBlvZB/ZEQvatjx8xcTeShq3M0f7SY0xdn3scnX84hul6jnhDa/a2YgtBM3F\nvfvKHZDsHwKBgBLU8gJDM3rRWCku4lKt9uqSf1w4ux1YmBaiNtLrllonHf88RGGi\n4vxmKV9MYEuYcfL/uguCSKWGF3o9C1Z/9fCh4HMoEK0RTwefdSuQ79zSU99hD7Yl\nNBYjTQYRRw3BEWPrt2fA1oVYOKT31AfS1Ar4zpReqbgukDKc/u+FRAOBAoGATOgo\ndnN0NsZ/1vHsYCYOpZ9NavqQuxSu6ZhQRpEPfAE8WsH3mzkqsFuZYWqo5j0Eg3jL\nHsWkWaomKeUfrbpvYhI/R55qHvKmnh307yMgi1cd7XdYTf4AS+/kDxY4/uWWQ7E4\nWKFecrECphXCPQapcgkL773aShtH/0/CPY3E+q0CgYEA1ZWl5MaTd77ZL8FICUjH\nWKFvkfhheWMr8UMdmUZKaIzIhs4+zDEpSp4lUcbmaJtSbjp7hC39CZVlwGuSc139\n9niQvFueUBZvogKbwgQJjOzQeTAZHVOfIMgEFlW8LDouJyPOrbsLriDvpjINIhVl\nDrvLrKmisVZSpO04Ftn6tao=\n-----END PRIVATE KEY-----\n",
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
