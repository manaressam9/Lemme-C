import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
//import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:volunteer_application/location_api/location_api.dart';

class TurnByTurnNavigation extends StatefulWidget {
  @override
  _TurnByTurnNavigationState createState() => _TurnByTurnNavigationState();
}

class _TurnByTurnNavigationState extends State<TurnByTurnNavigation> {
  late MapBoxNavigation _directions;
  late MapBoxOptions _mapBoxOptions;
  List<WayPoint> wayPoints = [];
  late MapboxMapController _controller;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    if (!mounted) return;
    _directions = MapBoxNavigation(onRouteEvent: (e) {
      setState(() {});
    });

    _mapBoxOptions = MapBoxOptions(
        zoom: 18.0,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        mode: MapBoxNavigationMode.walking,
        isOptimized: true,
        enableRefresh: true,
        units: VoiceUnits.metric,
        language: "en"
    );
  //  final  LocationData? location =await LocationApi.getCurrentLocation();
   /* final source =
        WayPoint(name: "Me", latitude: location!.latitude,longitude: location.longitude);*/
    /*final destination = WayPoint(
        name: "Destination", latitude: 30.18024887698403,longitude: 31.347161947137206  );
    wayPoints.add(source);
    wayPoints.add(destination);

    await _directions.startNavigation(
        wayPoints: wayPoints, options: _mapBoxOptions);*/
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('Mina')),
    );
  }
}
