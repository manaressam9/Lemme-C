import 'RouteData.dart';

class Response {
  String blindId;

  String volunteerId;

  String volunteerPhone;
  String volunteerName;

  RouteData? routeData;

  Response(
      {required this.blindId,
      required this.volunteerId,
      required this.volunteerPhone,
      required this.volunteerName,
      required this.routeData});


  static Response fromJson(Map<String, dynamic> json) {
    return Response(
      blindId: json['blindId'],
      volunteerId: json['volunteerId'],
      volunteerPhone: json['volunteerPhone'],
      volunteerName: json['volunteerName'],
      routeData: RouteData.fromJson(json['routeData']),
    );
  }
}
