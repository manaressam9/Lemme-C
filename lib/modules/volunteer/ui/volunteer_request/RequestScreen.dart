import 'package:flutter/material.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:vibration/vibration.dart';

import '../../../../shared/components.dart';
import '../../../../shared/styles/colors.dart';
import '../../../../strings/strings.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class RequestScreen extends StatefulWidget {
  VolunteerRequestCubit cubit;
  VolunteerRequestStates myState;

  RequestScreen(this.cubit, this.myState);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  double screenWidth = 0.0;

  double screenHeight = 0.0;

  @override
  void initState() {
    widget.cubit.onRequestInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = getScreenWidth(context);
    screenHeight = getScreenHeight(context);

    return InkWell(
      onTap: (){
        Vibration.vibrate(duration: 200);
        widget.cubit.onVolunteerRequest(widget.cubit);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Image(
              image: AssetImage(ASSISTANT_IMG),
              width: screenWidth / 2,
              height: screenHeight / 3.5,
            ),
            buildVerticalSpace(height: screenHeight / 5),
            widget.myState is RequestLoading
                ? CircularProgressIndicator(
                    backgroundColor: BLACK_COLOR, strokeWidth: 2)
                : widget.myState is RequestSucceeded
                    ? Text('Your request is sent for volunteers')
                    : buildDefaultBtn(
                        onPressed: () {
                          widget.cubit.onVolunteerRequest(widget.cubit);
                        },
                        txt: 'Ask for help',
                        context: context)
          ],
        ),
      ),
    );
  }
}
