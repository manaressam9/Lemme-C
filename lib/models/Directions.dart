import 'dart:ffi';

import '../shared/constants.dart';

class Directions {
  Map geometry;
  double duration, distance;

  Directions({
    required this.geometry,
    required this.distance,
    required this.duration,
  });

  static Directions? fromJson(Map<String, dynamic> json) {
    if ((json['routes'] as List).isNotEmpty) {
      Map<String, dynamic> route = json['routes'][0];
      return Directions(
        geometry: route['geometry'],
        distance: route['distance'],
        duration: route['duration'],
      );
    }
    return null;
  }
}
