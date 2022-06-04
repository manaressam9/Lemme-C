import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/volunteer_request_screen.dart';

import 'package:object_detection/shared/constants.dart';

import '../../../modules/currency_counter/currency_counter_screen.dart';
import '../../../modules/object_det/object_detection_screen.dart';
import '../../../modules/text_reader/text_reader_screen.dart';
import '../../../modules/volunteer/data/firebase/user_firebase.dart';
import '../../../strings/strings.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitState());

  static HomeCubit get(context) => BlocProvider.of(context);

  final List<Widget> navPages = [
    ObjectDetection(key: PageStorageKey<String>(OBJ_MOD_LABEL)),
    CurrencyCounter(
      key: PageStorageKey<String>(CURR_MOD_LABEL),
    ),
    TextReaderScreen(key: PageStorageKey<String>(Text_MOD_LABEL)),
    VolunteerRequestScreen(key: PageStorageKey<String>(VOLUNTEER_MOD_LABEL))
  ];
  int selectedIndex = 0;

  changeSelectedIndex(int index) {
    selectedIndex = index;
    emit(HomeNavigateState());
  }

  final List<String> navLabels = [
    OBJ_MOD_LABEL,
    CURR_MOD_LABEL,
    Text_MOD_LABEL,
    VOLUNTEER_MOD_LABEL
  ];

  Future<void> signOut() async {
    await UserFirebase.signOut();
    emit(HomeSignOutState());
  }

  checkRegistration() async {
    if (await checkConnection() && UserFirebase.isUserLogin()) {
      //navPages[3] = VolunteerScreen();
      showToast('connected and login');
      emit(HomeSignedInState());
    }
  }
}
