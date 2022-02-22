
class UserLocation {
  double _latitude, _longitude;

  UserLocation(this._latitude, this._longitude);

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

  static UserLocation fromJson(Map<String, dynamic> json) {
    return UserLocation(
      json['latitude'],
      json['longitude']
    );
  }



}
