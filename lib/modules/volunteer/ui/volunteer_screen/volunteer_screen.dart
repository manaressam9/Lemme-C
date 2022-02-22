import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/shared/components.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/strings/strings.dart';

import '../../../../shared/styles/colors.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';


class VolunteerScreen extends StatelessWidget {
  double screenWidth = 0, screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    screenHeight = getScreenHeight(context);
    screenWidth = getScreenWidth(context);
    return BlocProvider(
      create: (BuildContext context) => VolunteerCubit(),
      child: BlocConsumer<VolunteerCubit, VolunteerStates>(
        listener: (context, state) {
          if (State is RequestFailed)
            showToast('Your request is failed,try again');
        },
        builder: (context, state) {
          VolunteerCubit cubit = VolunteerCubit.get(context);
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(50),
            child: Column(
              children: [
                Image(
                  image: AssetImage(ASSISTANT_IMG),
                  width: screenWidth / 1.5,
                  height: screenHeight / 3,
                ),
                buildVerticalSpace(height: screenHeight / 4),
                state is RequestLoading
                    ? CircularProgressIndicator(
                        backgroundColor: BLACK_COLOR, strokeWidth: 2)
                    : state is RequestSucceeded
                        ? Text('Your request is sent for volunteers')
                        : buildDefaultBtn(
                            onPressed: () {
                              cubit.onVolunteerRequest();
                            },
                            txt: 'Ask for help',
                            context: context)
              ],
            ),
          );
        },
      ),
    );
  }
}
