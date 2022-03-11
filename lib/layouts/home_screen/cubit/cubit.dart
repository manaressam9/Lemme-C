import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';
import 'package:object_detection/modules/volunteer/ui/login/login_screen.dart';

import 'package:object_detection/shared/constants.dart';

import '../../../modules/currency_counter/currency_counter_screen.dart';
import '../../../modules/object_det/object_detection_screen.dart';
import '../../../modules/text_reader/text_reader_screen.dart';
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
    TextReaderScreen(),
   UserFirebase.isUserLogin() ?VolunteerScreen() : RegisterScreen()
  ];
  int selectedIndex = 0;
  List <Widget> getTabs ()
   {
     showToast('get tabs');
     return navPages;
   }
  changeSelectedIndex (int index)
  {
    selectedIndex = index;
    emit(HomeNavigateState());
  }

  void changeTab (int index,Widget screen){
    navPages[3]= screen;
    emit(HomeNavigateState());
  }

  navLoginOrReg(String logOrRegScreen) {
    if (navPages[3] is! VolunteerScreen) {
      if (logOrRegScreen == 'REGISTER')
        navPages[3] = RegisterScreen();
      else
        navPages[3] = LoginScreen();
    }
  }

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
      navPages[3] = VolunteerScreen();
      showToast('connected and login');
      emit(HomeSignedInState());
    }

  }
}
