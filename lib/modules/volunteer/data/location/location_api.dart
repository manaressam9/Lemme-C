import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

import 'package:object_detection/modules/volunteer/data/firebase/user_firebase.dart';
import 'package:object_detection/modules/volunteer/ui/register/cubit/cubit.dart';
import 'package:object_detection/shared/constants.dart';

import '../../../../models/UserLocation.dart';
import '../../../../models/Request.dart';
import '../../../../models/User.dart';
import '../../ui/register/cubit/states.dart';

class LocationApi {
 // static Location _location = new Location();
  static RegisterStates requestState = RequestFailed();



  static Future<void> sendRealTimeLocationUpdates() async {
   /* if (await _checkServiceAvailability() && await _checkLocationPermission()) {
      _listenOnLocationChange();
      showToast('Request is sent successfully');
    }
*/
    BackgroundLocation.setAndroidNotification(
      title: "Notification title",
      message: "Notification message",
      icon: "@mipmap/ic_launcher",
    );

   await BackgroundLocation.setAndroidConfiguration(1000);
    BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location)async {
      await _updateUserLocation(location.latitude, location.longitude);
    });

  }

  /*static Future<bool> _checkServiceAvailability() async {
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }
    return _serviceEnabled;
  }

  static Future<bool> _checkLocationPermission() async {
    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }
    return _permissionGranted == PermissionStatus.granted;
  }

  static StreamSubscription<LocationData>? _locationSubsrcibtion;

  static void _listenOnLocationChange()async {
   await _location.changeSettings(accuracy:LocationAccuracy.high, distanceFilter: 10);
    _locationSubsrcibtion = _location.onLocationChanged.handleError((onError) {
      _locationSubsrcibtion!.cancel();
      _locationSubsrcibtion = null;
    }).listen((locationData) async {
      await _updateUserLocation(locationData.latitude, locationData.longitude);
    });
  }
*/
  static Request? request;

  static _updateRequestObj(double latitude, double longitude) async {
    UserModel userModel = await getCurrentUser();
    if (request == null)
      request = Request(
          blindData: userModel,
          blindLocation: UserLocation(latitude, longitude),
          date: Timestamp.now());
    else {
      request!.blindLocation.latitude = latitude;
      request!.blindLocation.longitude = longitude;
    }
  }

  static Future<void> _updateUserLocation(
      double? latitude, double? longitude) async {
    _updateRequestObj(latitude!, longitude!);
    try {
      await UserFirebase.setRequestForAllVolunteers(request!);
      //requestState = RequestSucceeded();
    } catch (e) {
      print(e.toString());
    }
  }
}
