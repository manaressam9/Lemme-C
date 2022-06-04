import 'RouteData.dart';

class Response {
  String blindId;

  String volunteerId;

  String volunteerPhone;

  RouteData? routeData;

  Response(
      {required this.blindId,
      required this.volunteerId,
      required this.volunteerPhone,
      required this.routeData});

  Map<String, dynamic> toMap() {
    return {
      'blindId': blindId,
      'volunteerId': volunteerId,
      'volunteerPhone': volunteerPhone,
      'routeData': routeData != null ? routeData!.toMap() : null,
    };
  }

  static Response fromJson(Map<String, dynamic> json) {
    return Response(
      blindId: json['blindId'],
      volunteerId: json['volunteerId'],
      volunteerPhone: json['volunteerPhone'],
      routeData: RouteData.fromJson(json['routeData']),
    );
  }
}
