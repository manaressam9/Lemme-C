import 'dart:typed_data';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:volunteer_application/layouts/map_screen/cubit/states.dart';
import 'package:volunteer_application/location_api/location_api.dart';
import 'package:volunteer_application/map_helper/path_drawer.dart';
import 'package:volunteer_application/map_helper/transport_means.dart';
import 'package:volunteer_application/models/Directions.dart';
import 'package:volunteer_application/models/Request.dart';
import 'package:volunteer_application/models/UserLocation.dart';
import 'package:volunteer_application/shared/constants.dart';
import 'package:volunteer_application/shared/remote/user_firebase.dart';

import '../../../shared/remote/dio.dart';
import '../../../strings.dart';

class MapCubit extends Cubit<MapStates> {
  Directions? directions;

  MapCubit() : super(InitialMapState());

  static MapCubit get(context) => BlocProvider.of(context);

  listenOnBlindLocation(String blindId, MapboxMapController controller) async {
    UserFirebase.listenOnRequest(blindId).listen((DocumentSnapshot <Map<String,dynamic>> documentSnapshot)async {
      if (documentSnapshot.exists && documentSnapshot.data() != null)
        {
          Request request = Request.fromJson(documentSnapshot.data()!!);
          await getDirections(request.blindLocation,controller);
        }
    }).onError((err){
      showToast(err.toString());
    })
    ;
  }

  Future<void> getDirections(
      MyUserLocation destination, MapboxMapController controller) async {
    //source location
    LocationData? source = await LocationApi.getCurrentLocation();
    if (source == null) {
      return;
    }
    try {
      DioHelper.init();
      directions = await DioHelper.getDirections(
          destination: LatLng(destination.latitude, destination.longitude),
          origin: LatLng(source!.latitude!, source.longitude!),
          transportMean: TransportMeans.driving);
      await _drawRoute(controller: controller);
      //List<dynamic> coord = directions!.geometry['coordinates'];
      //LatLng southwest = (source.latitude! > destination.latitude)? LatLng(source.latitude!, source.longitude!) : LatLng(destination.latitude, destination.longitude);
      // LatLng northeast = (source.latitude! <= destination.latitude)? LatLng(source.latitude!, source.longitude!) : LatLng(destination.latitude, destination.longitude);
      /* controller.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest:  LatLng(destination.latitude,destination.longitude), northeast:LatLng(source.latitude!,source.longitude!))
      ,left: 100,right: 100,top: 100,bottom: 100));*/
      emit(DirectionsUpdated());
    } catch (e) {
      showToast(e.toString());
    }
  }

  bool iconInitialized = false;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _drawRoute({required MapboxMapController controller}) async {
    if (directions != null) {
      await PathDrawer.draw(directions!.geometry, controller);
    }
  }
}
