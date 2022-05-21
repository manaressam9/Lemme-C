
import 'package:mapbox_gl/mapbox_gl.dart';

class MyUserLocation {
  double _latitude, _longitude;

  MyUserLocation(this._latitude, this._longitude);

  get longitude => _longitude;

  set longitude(value) {
    _longitude = value;
  }

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': _latitude,
      'longitude': _longitude,
    };
  }

  static MyUserLocation fromJson(Map<String, dynamic> json) {
    return MyUserLocation(
      json['latitude'],
      json['longitude']
    );
  }

   getLatLongObject (){
    return LatLng(_latitude, _longitude);
  }




}
