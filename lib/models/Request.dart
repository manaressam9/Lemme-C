

import 'package:cloud_firestore/cloud_firestore.dart';

import '../shared/constants.dart';
import 'User.dart';
import 'UserLocation.dart';

class Request {
  UserModel blindData;
  UserLocation blindLocation;
  Timestamp date ;

  Request({required this.blindData, required this.blindLocation,required this.date});

  Map<String, dynamic> toMap() {
    return {
      'blindData': blindData.toMap(),
      'blindLocation': blindLocation.toMap(),
      'date': date,
    };
  }

  static Request fromJson(Map<String, dynamic> json) {
    return Request(
      blindData: UserModel.fromJson(json['blindData']) ,
      blindLocation: UserLocation.fromJson(json['blindLocation']),
      date: json['date']
    );
  }

  String getReadableDate() {
    DateTime requestDateTime = _fromTimeStamp();
    return handleDate(requestDateTime);
  }

  DateTime _fromTimeStamp() {
    return DateTime.fromMicrosecondsSinceEpoch(
         date.microsecondsSinceEpoch);
  }



}
