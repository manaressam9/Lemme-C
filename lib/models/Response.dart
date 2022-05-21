
import 'package:volunteer_application/models/Directions.dart';
import 'package:volunteer_application/models/UserLocation.dart';

import 'RouteData.dart';

class Response {
  String blindId ;
  String volunteerId ;
  RouteData? routeData ;

  Response({required this.blindId,required this.volunteerId ,required this.routeData});

  Map<String, dynamic> toMap() {
    return {
      'blindId': blindId,
      'volunteerId': volunteerId,
      'routeData': routeData != null? routeData!.toMap() : null,
    };
  }

  static Response fromJson(Map<String, dynamic> json) {
    return Response(
        blindId: json['blindId'] ,
      volunteerId: json['volunteerId'] ,
      routeData: RouteData.fromJson(json['routeData']),

    );
  }



}