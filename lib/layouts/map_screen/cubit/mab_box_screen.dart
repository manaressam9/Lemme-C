import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:volunteer_application/layouts/map_screen/cubit/states.dart';
import 'package:volunteer_application/models/UserLocation.dart';
import 'package:volunteer_application/shared/components.dart';
import 'package:volunteer_application/shared/styles/colors.dart';

import '../../../shared/constants.dart';
import '../../../strings.dart';
import 'cubit.dart';

class MabBoxScreen extends StatelessWidget {
  late final MyUserLocation location;
  late final String phone;
  late CameraPosition _initialCameraPosition;

  MabBoxScreen(this.location, this.phone) {
    _initialCameraPosition = CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 10,
    );
  }

  late MapCubit cubit;
  double screenWidth = 0;
  double screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    screenHeight = getScreenHeight(context);
    screenWidth = getScreenWidth(context);
    return BlocProvider(
      create: (context) => MapCubit(),
      child: BlocConsumer<MapCubit, MapStates>(
        listener: (_, __) => {},
        builder: (context, state) {
          cubit = MapCubit.get(context);
          // directions = cubit.directions;
          return Scaffold(
            appBar: AppBar(
              title: const Text('See on map'),
            ),
            body: Stack(
              alignment: Alignment.bottomRight, // Just changed this line
              children: [
                _createMapBoxMap(),
                if (cubit.directions != null) _createBottomCardView()
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _createMapBoxMap() {
    return MapboxMap(
      initialCameraPosition: _initialCameraPosition,
      accessToken: MAPBOX_PUBLIC_TOKEN,
      myLocationEnabled: true,
      onMapCreated: (controller) async {
        const _marker = 'marker';
        controller.addImage(
            _marker, await cubit.getBytesFromAsset(MARKER_ICON, 64));
        controller.addSymbol(_createMarker(_marker));
        if (cubit.directions == null)
         await cubit.getDirections(location, controller);
      },
    );
  }

  SymbolOptions _createMarker(String imageName) {
    return SymbolOptions(
      geometry: LatLng(location.latitude, location.longitude),
      iconSize: 1.5,
      iconImage: imageName,
      // textField: 'Destination',
    );
  }

  _createBottomCardView() => Container(
        height: screenHeight / 10,
        width: double.infinity,
        child: Card(
          color: PRIMARY_SWATCH,
          child: Row(
            children: [
              buildHorizontalSpace(),
              Text(
                '${(cubit.directions!.duration / 60).round()} min',
                style: const TextStyle(
                    fontFamily: LIGHT_FONT,
                    fontSize: 16,
                    color: Colors.black54),
              ),
              buildHorizontalSpace(),
              Text('${(cubit.directions!.distance / 1000).round()} Km',
                  style: const TextStyle(
                      fontFamily: LIGHT_FONT,
                      fontSize: 16,
                      color: Colors.black54)),
              const Spacer(),
              _buildCallingIcon(),
              buildHorizontalSpace()
            ],
          ),
        ),
      );

  Widget _buildCallingIcon() => InkWell(
      onTap: () {
        callPhone(phone);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: MAIN_COLOR,
            child: Icon(
              Icons.phone,
              color: PRIMARY_SWATCH,
              size: 25,
            ),
          ),
          buildVerticalSpace(height: 5),
          const Text(
            'Call',
            style: TextStyle(
                color: Colors.black54, fontSize: 12, fontFamily: LIGHT_FONT),
          ),
        ],
      ));
}
