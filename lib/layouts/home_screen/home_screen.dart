import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/cubit.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';
import 'package:object_detection/modules/volunteer/ui/login/login_screen.dart';
import 'package:object_detection/modules/volunteer/ui/register/register_screen.dart';

import 'package:object_detection/shared/styles/icons.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:object_detection/ui/camera_controller.dart';

import '../../modules/volunteer/data/firebase/user_firebase.dart';
import '../../shared/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex;
  final String loginOrReg;

  const HomeScreen({this.selectedIndex = 0, this.loginOrReg = 'REGISTER'});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState(selectedIndex, loginOrReg);
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex;
  String loginOrReg;

  _HomeScreenState(this.selectedIndex, this.loginOrReg);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()
        ..checkRegistration()
        ..navLoginOrReg(loginOrReg),
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (_, __) => {},
        builder: (context, state) {
          HomeCubit cubit = HomeCubit.get(context);
          return DefaultTabController(
            length: 4,
            initialIndex: selectedIndex,
            child: Scaffold(
              backgroundColor: PRIMARY_SWATCH,
              appBar: AppBar(
                title: Text('Blind Assistant',style: TextStyle(fontFamily: BOLD_FONT),),
                titleSpacing: 20,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Image(
                    image: AssetImage(GLASSES_IMG),
                  ),
                ),
                leadingWidth: 50,
                actions: [
                  selectedIndex == 3 && UserFirebase.isUserLogin()
                      ? IconButton(
                          onPressed: () {
                            {
                              cubit.signOut();
                            }
                          },
                          icon: Icon(Icons.logout))
                      : Container()
                ],
                bottom:const TabBar
                  (
                  tabs: [
                  Tab(icon: Icon(CustomIcons.object)),
                  Tab(icon:  Icon(CustomIcons.money)),
                  Tab(icon: Icon(CustomIcons.document)),
                  Tab(icon: Icon(CustomIcons.volunteer)),
                ],
                labelColor: MAIN_COLOR,
                indicatorColor: BLACK_COLOR,
                ),
              ),
              body:/* cubit.navPages[selectedIndex]*/
              Padding(
                padding: EdgeInsets.all(8),
                  child: TabBarView(
                    children:
                      cubit.navPages,
                  ),

              ),



             /* bottomNavigationBar: BottomNavigationBar(
                unselectedItemColor: GREY_COLOR,
                selectedItemColor: BLACK_COLOR,
                selectedIconTheme: IconThemeData(color: MAIN_COLOR),
                selectedFontSize: 13,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.object), label: '$OBJ_MOD_LABEL'),
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.money), label: '$CURR_MOD_LABEL'),
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.document),
                      label: '$Text_MOD_LABEL'),
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.volunteer),
                      label: '$VOLUNTEER_MOD_LABEL'),
                ],
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),*/
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    CameraControllerFactory.cameraControllers.clear();
    super.dispose();
  }

}
