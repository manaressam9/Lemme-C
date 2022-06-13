import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/RegisterScreen.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/RequestScreen.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/response/ResponseScreen.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/login_screen.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/phone_Verification_screen.dart';
import '../../../../layouts/home_screen/home_screen.dart';
import '../../../../shared/constants.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class VolunteerRequestScreen extends StatefulWidget {
  const VolunteerRequestScreen({Key? key}) : super(key: key);

  static late Function setState;

  @override
  State<VolunteerRequestScreen> createState() => _VolunteerRequestScreenState();
}

class _VolunteerRequestScreenState extends State<VolunteerRequestScreen>
    with WidgetsBindingObserver {
  double screenHeight = 0.0;

  double screenWidth = 0.0;
  late VolunteerRequestCubit cubit;

  VolunteerRequestStates myState = RegisterInitState();

  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      VolunteerRequestCubit()
        ..onVolunteerInit(),
      child: BlocConsumer<VolunteerRequestCubit, VolunteerRequestStates>(
        listener: (context, state) {
          myState = state;
          if (myState is RegisterFirstStageCompletedState ||
              myState is LoginFirstStageCompletedState)
            navigate(context, PhoneVerificationScreen(cubit, 'REGISTER'));
          else if (myState is VerificationSuccessState)
            navigateAndFinish(context,HomeScreen(verified: true));
          else if (myState is RegisterErrorState)
            showToast((myState as RegisterErrorState).errorMsg);
          else if (myState is RequestFailed)
            showToast('Request failed, try again');
          else if (myState is RequestSucceeded) showToast('Request is sent');
        },
        builder: (context, state) {
          cubit = VolunteerRequestCubit.get(context);
          screenHeight = getScreenHeight(context);
          screenWidth = getScreenWidth(context);
          /*if (myState is RequestSucceeded) {
            cubit.listenOnResponseIfExist();
          }*/
          return Scaffold(
            body: cubit.isUserLogin()
                ? FutureBuilder(
                future: cubit.isRequestSent(),
                builder: (context, data) {
                  if (data.hasData && data.data == true) {
                    /* if (firstTime) {
                          cubit.listenOnResponseIfExist();
                          firstTime = false;
                        }
                        return buildResponseScreen(state);*/
                    return ResponseScreen();
                  } else
                    return RequestScreen(cubit, state);
                })
                : cubit.loginOrReg == 'REGISTER'
                ? RegisterScreen(cubit, state)
                : LoginScreen(cubit, state),
          );
        },
      ),
    );
  }

/*  // response screen
   Widget buildResponseScreen(state) {
     return state is ResponseSent && cubit.response != null
        ? ResponseScreen(
            cubit.response!.routeData!.duration.toInt(),
            cubit.response!.routeData!.distance.toInt(),
            cubit.response!.volunteerPhone)
        : WaitingScreen();
  }*/



  @override
  void dispose() {
    // TODO: implement dispose
    //cubit.onDispose();
    super.dispose();
  }

}
