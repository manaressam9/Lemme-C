import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/cubit/cubit.dart';
import 'package:object_detection/layouts/home_screen/cubit/states.dart';
import 'package:object_detection/layouts/splach_layout.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/shared/styles/icons.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:vibration/vibration.dart';
import '../../modules/currency_counter/currency_counter_screen.dart';
import '../../modules/object_det/object_detection_screen.dart';
import '../../modules/volunteer/data/firebase/user_firebase.dart';
import '../../modules/volunteer/ui/volunteer_request/volunteer_request_screen.dart';
import '../../shared/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  static late HomeCubit cubit;
  final String loginOrReg;
  final bool verified;

  const HomeScreen({this.loginOrReg = 'REGISTER', this.verified = false});

  @override
  State<HomeScreen> createState() => HomeScreenState(loginOrReg, verified);
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String loginOrReg;
  bool verified;

  HomeScreenState(this.loginOrReg, this.verified);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 4);
    if (verified) _tabController.animateTo(3);

    _tabController.addListener(() async {
      if (_tabController.index == 0 &&
          ObjectDetection.cameraView != null &&
          !ObjectDetection.cameraView!.firstTime) {
        ObjectDetection.cameraView?.initializeCamera();
        showToast("index 0");
      } else if (_tabController.index == 1 &&
          !CurrencyCounter.cameraView!.firstTime) {
        CurrencyCounter.cameraView?.initializeCamera();
        showToast("index 1");
      }
      /*else if (_tabController.index == 2){
         await cameraController!.stopImageStream();
    }*/
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) => {setState(() {})},
        builder: (context, state) {
          HomeScreen.cubit = HomeCubit.get(context);
          return Scaffold(
            backgroundColor: PRIMARY_SWATCH,
            appBar: AppBar(
              title: Text(
                APP_NAME,
                style: TextStyle(fontFamily: BOLD_FONT),
              ),
              titleSpacing: 20,
              leading: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Image(
                  image: AssetImage(LOGO_IMG),
                ),
              ),
              leadingWidth: 50,
              elevation: 7,
              actions: [
                HomeScreen.cubit.selectedIndex == 3 &&
                        UserFirebase.isUserLogin()
                    ? IconButton(
                        onPressed: () {
                          Vibration.vibrate(duration: 200);
                          _displayDialog(context);
                        },
                        icon: Icon(Icons.logout))
                    : IconButton(
                        onPressed: () {
                          Vibration.vibrate(duration: 200);
                          navigateAndFinish(context, SplachScreen());
                        },
                        icon: Icon(Icons.login_sharp))
              ],
              bottom: TabBar(
                controller: _tabController,
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
                controller: _tabController,
                children: HomeScreen.cubit.navPages,
              ),
            ),
          );
        },
      ),
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Are you want to sign out?',
              style: TextStyle(fontSize: 13, color: MAIN_COLOR),
            ),
            actions: <Widget>[
              MaterialButton(
                child: const Text('Yes'),
                onPressed: () async {
                  await HomeScreen.cubit.signOut();
                  _tabController.animateTo(3);
                  VolunteerRequestScreen.setState();
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
