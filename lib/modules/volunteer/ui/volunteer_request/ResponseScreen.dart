import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/models/Response.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/cubit/states.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/cubit/waiting_screen.dart';
import 'package:object_detection/shared/components.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/shared/styles/colors.dart';

import '../../../../utils/tts_utils.dart';

class ResponseScreen extends StatefulWidget {
  Response response;
  bool responseReceived;
  Function listenOnResponseIfExist;

  ResponseScreen(
      this.responseReceived, this.response, this.listenOnResponseIfExist);

  @override
  State<ResponseScreen> createState() =>
      _ResponseScreenState(responseReceived, response,listenOnResponseIfExist);
}

class _ResponseScreenState extends State<ResponseScreen> {
  Response response;
  bool responseReceived;
  Function listenOnResponseIfExist;

  _ResponseScreenState(
      this.responseReceived, this.response, this.listenOnResponseIfExist);

  @override
  void initState() {
    // TODO: implement initState
    listenOnResponseIfExist();
    if (responseReceived) _speakResponseInformation();

    super.initState();
  }

  void _speakResponseInformation() async {
    final FlutterTts flutterTts = FlutterTts();
    flutterTts.setQueueMode(1);
    await flutterTts.speak("Cool, volunteer accept your request");
    await flutterTts.speak("Your volunteer will arrive after${response.routeData!.duration} minutes");
    await flutterTts.speak(
        "The distance between you and your volunteer is ${response.routeData!.distance} kilometers");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    return responseReceived
        ? Stack(
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
                              Center(
                                child: Text(
                                  "${response.routeData!.duration} minutes",
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
                              Text(
                                "${response.routeData!.distance} km",
                                style:
                                    TextStyle(color: BLACK_COLOR, fontSize: 16),
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
                      directPhoneCall("${response!.volunteerPhone}");
                    },
                    child: Icon(Icons.phone),
                  ),
                ),
              )
            ],
          )
        : WaitingScreen();
  }
}
