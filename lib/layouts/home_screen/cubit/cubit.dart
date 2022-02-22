import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';

import 'package:object_detection/shared/constants.dart';

import '../../../modules/currency_counter/currency_counter_screen.dart';
import '../../../modules/object_det/object_detection_screen.dart';
import '../../../modules/text_reader/camera_preview_scanner.dart';
import '../../../modules/volunteer/data/firebase/user_firebase.dart';
import '../../../modules/volunteer/ui/register/register_screen.dart';
import '../../../modules/volunteer/ui/volunteer_screen/volunteer_screen.dart';
import '../../../strings/strings.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitState());

  static HomeCubit get(context) => BlocProvider.of(context);

  final List<Widget> navPages = [
    ObjectDetection(),
    CurrencyCounter(),
    CameraPreviewScanner(),
    RegisterScreen()
  ];
  final List<String> navLabels = [
    OBJ_MOD_LABEL,
    CURR_MOD_LABEL,
    Text_MOD_LABEL,
    VOLUNTEER_MOD_LABEL
  ];

  void signOut() {
    UserFirebase.signOut();
    navPages[navPages.length - 1] = RegisterScreen();
    emit(HomeSignOutState());
  }

  checkRegistration() async {
    if (await checkConnection() && UserFirebase.isUserLogin()) {
      navPages[navPages.length - 1] = VolunteerScreen();
      emit(HomeSignedInState());
    }
  }
}
