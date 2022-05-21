import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:volunteer_application/models/Directions.dart';
import 'package:volunteer_application/models/RouteData.dart';
import '../models/Request.dart';
import '../models/Response.dart';
import '../models/User.dart';
import '../models/UserLocation.dart';
import '../shared/constants.dart';
import '../shared/remote/user_firebase.dart';


class LocationApi {

  static final loc.Location _location = loc.Location();
  //static VolunteerStates requestState = RequestFailed();
  static late final LatLng _destination ;
  static late final String _blindId ;


  static Future<void> sendRealTimeLocationUpdates(LatLng blindDestination,String blindId) async {
    if (await checkServiceAvailability() && await checkLocationPermission()) {
      _listenOnLocationChange();
    }
    _destination = blindDestination;
    _blindId = blindId;
  }

  static Future<loc.LocationData?> getCurrentLocation ()async
  {
    if (await checkServiceAvailability() && await checkLocationPermission()) {
      return _location.getLocation();
    }
    return null;
  }

  static Future<bool> checkServiceAvailability() async {
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
    }
    return _serviceEnabled;
  }

  static Future<bool> checkLocationPermission() async {
    loc.PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }
    return _permissionGranted == loc.PermissionStatus.granted;
  }

  static StreamSubscription<loc.LocationData>? _locationSubsrcibtion;

  static void _listenOnLocationChange() {
    _locationSubsrcibtion = _location.onLocationChanged.handleError((onError) {
      _locationSubsrcibtion!.cancel();
      _locationSubsrcibtion = null;
    }).listen((locationData) async {
      await _updateUserLocation(locationData.latitude, locationData.longitude);
    });
  }

  static Response? response;

   static Future<RouteData?> _getRouteData (double latitude,double longitude)async{
    Directions? directions = await getSourceDestinationDistance(_destination,LatLng(latitude, longitude));
    return directions != null ?  RouteData(distance: directions.distance, duration: directions.duration) : null;
  }

  static _updateResponseObj(double latitude, double longitude) async {
     // calculate the new routeData - duration and distance - between the source and destination
   RouteData? routeData = await _getRouteData(latitude,longitude);
    if (response == null) {
      response = Response(
          blindId: _blindId,
          volunteerId: UserFirebase.getUid(),
          routeData :routeData);}
    else {
      response!.routeData = routeData;
    }
  }

  static Future<void> _updateUserLocation(
      double? latitude, double? longitude) async {
    _updateResponseObj(latitude!, longitude!);
    try {
      await UserFirebase.sendResponse(response!);
     // requestState = RequestSucceeded();
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<Placemark> getPlaceFromCoordinates (double lat , double long)async
  {
    List <Placemark> placeMarks = await placemarkFromCoordinates(lat,long);
    return placeMarks[0];
  }

}
