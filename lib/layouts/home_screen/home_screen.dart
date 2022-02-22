import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/cubit.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';


import 'package:object_detection/shared/styles/icons.dart';
import 'package:object_detection/strings/strings.dart';

import '../../modules/volunteer/data/firebase/user_firebase.dart';
import '../../shared/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex;

  const HomeScreen({this.selectedIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState(selectedIndex);
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex;

  _HomeScreenState(this.selectedIndex);


  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context)=> HomeCubit()..checkRegistration(),
    child: BlocConsumer<HomeCubit,HomeStates>(
      listener: (_,__)=>{},
      builder: (context,state){
        HomeCubit cubit = HomeCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            title: Text('${cubit.navLabels[selectedIndex]}'),
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
          ),
          body: cubit.navPages[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
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
                  icon: Icon(CustomIcons.document), label: '$Text_MOD_LABEL'),
              BottomNavigationBarItem(
                  icon: Icon(CustomIcons.volunteer), label: '$VOLUNTEER_MOD_LABEL'),
            ],
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
        );
      },
    ),);
  }
}
