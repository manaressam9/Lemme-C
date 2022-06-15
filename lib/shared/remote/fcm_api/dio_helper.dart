
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      String title, String body, String url) async{
    return await dio.post('send', data: getData(title, body, url));
  }

  static Map getData(String title, String body, String url) => {
        "to":'${FirebaseMessaging.instance.getToken()}',
        "notification": {
          "title": "$title",
          "body": "$body",
          "mutable_content": true,
          "sound": "default"
        },
        "data": {"url": "$url"}
      };
}
