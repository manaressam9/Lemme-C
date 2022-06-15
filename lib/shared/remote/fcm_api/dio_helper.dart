
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../strings.dart';

class FcmDioHelper {
  static late Dio dio;

  static const baseUrl = 'https://fcm.googleapis.com/fcm/';

  static init() {
    dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "key=$FCM_SERVER_KEY"
        }));
  }

  static Future<Response> pushFcmNotification (
      String title, String body) async{
    return await dio.post('send', data: getData(title, body));
  }

  static Map getData(String title, String body) => {
        "to":'${FirebaseMessaging.instance.getToken()}',
        "notification": {
          "title": "$title",
          "body": "$body",
          "mutable_content": true,
          "sound": "default"
        },
      //  "data": {"url": "$url"}
      };
}
