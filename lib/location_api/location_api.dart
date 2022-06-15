import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:geocoding/geocoding.dart';

import 'package:location/location.dart' as loc;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:volunteer_application/models/Directions.dart';
import 'package:volunteer_application/models/RouteData.dart';
import '../models/Response.dart';
import '../shared/constants.dart';
import '../shared/remote/user_firebase.dart';
import '../strings.dart';

class LocationApi {
  static final loc.Location _location = loc.Location();
  static late final LatLng _destination;

  static late final String _blindId;
  static late final String volunteerPhone;

  static Future<void> sendResponseWithRealTimeLocationChanges(
      LatLng blindDestination, String blindId, String vPhone) async {
    BackgroundLocation.setAndroidNotification(
        title: "Volunteer App",
        message: "Location real time updates are be sending to the blind",
        icon: GLASSES_IMG);
    // listen on location changes every 1 minute
    BackgroundLocation.setAndroidConfiguration(60000);
    BackgroundLocation.startLocationService();
    _listenOnLocationChange();
    _destination = blindDestination;
    _blindId = blindId;
    volunteerPhone = vPhone;
  }

  static Future<loc.LocationData?> getCurrentLocation() async {
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

  static void _listenOnLocationChange() {
    BackgroundLocation.getLocationUpdates((location) async {
      await _updateUserLocation(location.latitude, location.longitude);
    });
  }

  static Response? response;

  static Future<RouteData?> _getRouteData(
      double latitude, double longitude) async {
    Directions? directions = await getSourceDestinationDistance(
        _destination, LatLng(latitude, longitude));
    return directions != null
        ? RouteData(
            distance: directions.distance, duration: directions.duration)
        : null;
  }

  static _updateResponseObj(double latitude, double longitude) async {
    // calculate the new routeData - duration and distance - between the source and destination
    RouteData? routeData = await _getRouteData(latitude, longitude);
    if (response == null) {
      response = Response(
          blindId: _blindId,
          volunteerId: UserFirebase.getUid(),
          routeData: routeData, volunteerPhone: volunteerPhone );
    } else {
      response!.routeData = routeData;
    }
  }

  static bool firstTime = true;

  static Future<void> _updateUserLocation(
      double? latitude, double? longitude) async {
    _updateResponseObj(latitude!, longitude!);
    try {
      // update the response every time location change, and update request fields (state,volunteerId) only on the first time
      await UserFirebase.sendResponse(response!);
      firstTime = false;
      // requestState = RequestSucceeded();
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<Placemark> getPlaceFromCoordinates(
      double lat, double long) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, long,localeIdentifier: "en_US");
    return placeMarks[0];
  }
}
