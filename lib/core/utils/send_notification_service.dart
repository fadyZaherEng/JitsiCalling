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
        "dfM1vCj3S_yShAyA2ghFOi:APA91bFrX7VfBK29A5zNbS76myv967nASi2TGvovDDN9REmNAmDBslnYBYKkcorMUx-wDx2zRi7-BHrOoYa_DFjOB7v4_o07OzfATAbZ8AekbldF2YOwmbc";
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
      "private_key_id": "b7a944111e2b557e0a8de5045975d4c6bdf8e368",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC53s6k7SQ5rt8t\nfz2sWi11CpFLxXITTnku6IRAkBoBAYGGEj7usF9Qk0SsI+gYWRl7aKqnW8IY23pj\nn1qS0CAe+MfwlaOxKhVsMfkSIhRA8LxjHVngdF0xX5lenIX1IK51/8W3ZoTieCRl\nbdfA/Vi9m2QKI6SfooYZ5wutxLy3uKUktGcHiBIypjT4eWhPGonbWImcwpp/s3xs\nE8wnV7nQplyMXz/hS6LjkXk/RjqWb27IX37rxKIIrZ2L1r3t1TSi9VuCpNj1ZHLx\nhsBh4VAQbRQjbxOByLPbMg1IgBnDF5ni3uOxwuTTRyNZQ0FbbSEoLTUsBB8mNdk7\nuRRdNDFbAgMBAAECggEAJt+I82hfY6sFpSPP97xydmCL679zMMOAR8W8Zy5cKeqx\nNqOZQt1jSdxLB/+IepMj57IHwvHHYeCBM9WvoTXjCec5FcGOFy74hQTclSTIfJ58\nn/QTCIT9uqZGUsnEoHRB2I7yQH2x/BVpc0cqUQQLa7hUj2RN+U8J4d/3CtQzLe8V\n24vb0EtoLR4kDvfyMsPXLRgexLqdfVoBC0JDmH0MJ3k8q/+HYaJ+XScJSLISGTqt\nEpreERccJ1/m057ggrDRxaLNJobxogKRZdBhOfBk+AT9blJL2Cq+ZrpvRcgAmtgq\nO0Sv4NrJaedS4P7/DaarRsFeY4hF17IY1/YYsb96lQKBgQDzdGfHzGPY6EShJ83r\n75/L2ru9JZGN7FBO/59ro1s8YuqpkxZKgpCe3DDkPmeRXHuzznf0LpOG/KIe+nOE\ns+6SNapgPJLy+a0rtn6doJ/COP5f9098gnhg60lREUb1imW+ZeIJge8b0Wk6nfnQ\noG+putQYfH7Pxvn26oxBqTqXpwKBgQDDcsNT99V2WJkVPLok9ZtMOyQ66pwmXD4u\nAc+b3gIP/SFF0cT8tQf8G1+HKMH+ympmbaOn/Qlpcfc5zqBmA1RAh+W1QX4CPip4\n1vHHP77hWWYkJWeY0ayZBiztCLiUIRKCxb8coWQu+OgaA9KH1Nqdt4p0Z8AUlfzK\nn7bRMW1PLQKBgQDDJs6CFE79csKAxF2HASCA0qenaVQSBhoiGTp7mAjskQY2RFec\nBqlTDoKKk5OFrDLk4V66eBN+I0j5uB2dhHZ68VXPqv7IkmfEIJfCVx15HSKbXq1y\ny0sftbuhpk3RSc1hIF5e7K71B5poiHXWTKT103Ns5W7ps0BwM3eWssbrBQKBgQCp\nCNA2BtnvCKEc5PB4lpJBU8T5z35NDuoYECjlvRQ7j8j/AXVEuay2NVZhJrbhDV8I\nRzqLRySktZQDwtimYaq0RNQ99u5sMie5auygTllfvFnCWTdHy89iaRzhw/Ee65t+\nzleDA3IJzeuu1C94mnaYgOyV0EUniLCg7ZDHS+Al4QKBgAmZOH8eBAPJD8ErDCts\ndaFl63J035vo7CGxYHB7XDtPkB4OckO/hv0fb4niAI/ueeptXlnX7MuEdyjutFqh\nHUtCNbMu6ovrGWDNY+Uh9JpBNUcQRnmD8HVYcNc+KnbUqLIFpXX2dOLblkX+/xZS\nZo6JM8AgoV1NcriaKnUhpE37\n-----END PRIVATE KEY-----\n",
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
