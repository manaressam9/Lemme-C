import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/cubit.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';
import 'package:object_detection/modules/volunteer/ui/register/register_screen.dart';
import 'package:object_detection/shared/constants.dart';

import 'package:object_detection/shared/styles/icons.dart';
import 'package:object_detection/strings/strings.dart';

import '../../modules/volunteer/data/firebase/user_firebase.dart';
import '../../shared/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  static late HomeCubit cubit;
  final String loginOrReg;

  const HomeScreen({this.loginOrReg = 'REGISTER'});

  @override
  State<HomeScreen> createState() => HomeScreenState(loginOrReg);
}

class HomeScreenState extends State<HomeScreen> {
  String loginOrReg;

  HomeScreenState(this.loginOrReg);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) => {setState(() {})},
        builder: (context, state) {
          HomeScreen.cubit = HomeCubit.get(context);
          return DefaultTabController(
            length: 4,
            initialIndex: HomeScreen.cubit.selectedIndex,
            child: Scaffold(
              backgroundColor: PRIMARY_SWATCH,
              appBar: AppBar(
                title: Text(
                  'Blind Assistant',
                  style: TextStyle(fontFamily: BOLD_FONT),
                ),
                titleSpacing: 20,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Image(
                    image: AssetImage(GLASSES_IMG),
                  ),
                ),
                leadingWidth: 50,
                actions: [
                  HomeScreen.cubit.selectedIndex == 3 &&
                          UserFirebase.isUserLogin()
                      ? IconButton(
                          onPressed: () {
                            {
                              HomeScreen.cubit.signOut();
                              HomeScreen.cubit.navPages[3] = RegisterScreen();
                              setState(() {});
                            }
                          },
                          icon: Icon(Icons.logout))
                      : Container()
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(CustomIcons.object)),
                    Tab(icon: Icon(CustomIcons.money)),
                    Tab(icon: Icon(CustomIcons.document)),
                    Tab(icon: Icon(CustomIcons.volunteer)),
                  ],
                  labelColor: MAIN_COLOR,
                  indicatorColor: BLACK_COLOR,
                ),
              ),
              body: /* cubit.navPages[selectedIndex]*/
                  Padding(
                padding: EdgeInsets.all(8),
                child: TabBarView(
                  children: HomeScreen.cubit.navPages,
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
}
