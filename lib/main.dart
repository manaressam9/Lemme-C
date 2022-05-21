import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volunteer_application/layouts/register/register_screen.dart';
import 'package:volunteer_application/shared/constants.dart';
import 'package:volunteer_application/shared/styles/colors.dart';
import 'package:volunteer_application/strings.dart';

import 'layouts/RequestsScreen/RequestsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await checkConnection()) await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Widget startScreen = await isLogin() ? RequestsScreen() : RegisterScreen();
  runApp(MyApp(startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp(this.startScreen, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Volunteer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: PRIMARY_SWATCH,
            fontFamily: REGULAR_FONT,
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                  color: BLACK_COLOR, fontFamily: REGULAR_FONT, fontSize: 17),
              titleSpacing: 10,
              elevation: 0.5,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: MAIN_COLOR,
              ),
            )),
        //  home: UserFirebase.isUserLogin()? RequestsScreen() : RegisterScreen(),
        home: startScreen);
  }
}
