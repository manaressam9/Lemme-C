import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/models/Response.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/response/waiting_screen.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/response/cubit/cubit.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/response/cubit/states.dart';
import 'package:object_detection/shared/components.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/shared/styles/colors.dart';
import 'package:vibration/vibration.dart';

import '../../../../../utils/tts_utils.dart';

class ResponseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    late ResponseCubit cubit;
    double screenWidth = getScreenWidth(context);
    return BlocProvider(
      create: (context) =>
      ResponseCubit()
        ..listenOnResponseIfExist(),
      child: BlocConsumer<ResponseCubit, VolunteerResponseStates>(
        listener: (context, state) {
          if (state is ResponseSent) {
            cubit.speakResponseInformation();
          }
          if (state is ResponseWaited){
            cubit.speakResponseWaited();
          }
        },
        builder: (context, state) {
          cubit = ResponseCubit.get(context);
          return cubit.response != null
              ? InkWell(
            onTap: () {
              Vibration.vibrate(duration: 200);
              directPhoneCall(
                  "${cubit.response!.volunteerPhone}");
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        buildVerticalSpace(),
                        CircleAvatar(
                          radius: screenWidth / 3.5,
                          backgroundColor: MAIN_COLOR,
                          child: CircleAvatar(
                            backgroundColor: GREY_COLOR,
                            radius: screenWidth / 3.6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Duration",
                                  style: TextStyle(color: WHITE_COLOR),
                                ),
                                buildVerticalSpace(),
                                Center(
                                  child: Text(
                                    "${(cubit.response!.routeData!.duration /
                                        60).toInt()} minutes",
                                    style: TextStyle(
                                        color: BLACK_COLOR, fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        CircleAvatar(
                          radius: screenWidth / 3.5,
                          backgroundColor: MAIN_COLOR,
                          child: CircleAvatar(
                            radius: screenWidth / 3.6,
                            backgroundColor: GREY_COLOR,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Distance",
                                  style: TextStyle(color: WHITE_COLOR),
                                ),
                                buildVerticalSpace(),
                                Text(
                                  "${(cubit.response!.routeData!.distance /
                                      1000).toInt()} km",
                                  style: TextStyle(
                                      color: BLACK_COLOR, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        directPhoneCall(
                            "${cubit.response!.volunteerPhone}");
                      },
                      child: Icon(Icons.phone),
                    ),
                  ),
                )
              ],
            ),
          )
              : WaitingScreen();
        },
      ),
    );
  }
}
