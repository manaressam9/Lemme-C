import 'package:dio/dio.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:volunteer_application/models/Directions.dart';

import '../../strings.dart';
import '../constants.dart';

class DioHelper {
  static late Dio _dio;
  static const _baseUrl = 'https://api.mapbox.com/directions/v5/mapbox';

  static init() {
    _dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        receiveDataWhenStatusError: true,
        contentType: Headers.jsonContentType));
  }

  static Future<Directions?> getDirections(
      {required LatLng destination,
      required LatLng origin,
      required transportMean}) async {
    Response response = await _dio.get(
        '/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?continue_straight=true&geometries=geojson&language=en&overview=full&steps=true&access_token=$MAPBOX_PUBLIC_TOKEN');
    if (response.statusCode == 200) {
      return Directions.fromJson(response.data);
    }
    showToast(response.statusMessage.toString());
    return null;
  }
}
