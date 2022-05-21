import 'UserLocation.dart';

class UserModel {
  String nationalId = '';
  String fullName = '';
  String phone = '';
  String key = '';
  MyUserLocation? location;
  String? picture;

  UserModel(
      {required this.nationalId,
      required this.fullName,
      required this.phone,
      required this.key,
      this.location,
      this.picture});

  UserModel.fromUser();

  Map<String, dynamic> toMap() {
    return {
      'nationalId': nationalId,
      'fullName': fullName,
      'phone': phone,
      'key': key,
      'location': location,
      'picture': picture
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
        nationalId: json['nationalId'],
        fullName: json['fullName'],
        phone: json['phone'],
        key: json['key'],
        location: json["location"],
        picture: json["picture"]);
  }
}
