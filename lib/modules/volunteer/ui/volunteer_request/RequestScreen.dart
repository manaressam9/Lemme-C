import 'package:flutter/material.dart';
import 'package:object_detection/shared/constants.dart';

import '../../../../shared/components.dart';
import '../../../../shared/styles/colors.dart';
import '../../../../strings/strings.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class RequestScreen extends StatelessWidget {
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  VolunteerRequestCubit cubit;
  VolunteerRequestStates myState;

  RequestScreen(this.cubit, this.myState);

  @override
  Widget build(BuildContext context) {
    screenWidth = getScreenWidth(context);
    screenHeight = getScreenHeight(context);

    return Container(
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
          myState is RequestLoading
              ? CircularProgressIndicator(
                  backgroundColor: BLACK_COLOR, strokeWidth: 2)
              : myState is RequestSucceeded
                  ? Text('Your request is sent for volunteers')
                  : buildDefaultBtn(
                      onPressed: () {
                        cubit.onVolunteerRequest(cubit);
                      },
                      txt: 'Ask for help',
                      context: context)
        ],
      ),
    );
  }
}
