import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/layouts/splach_layout.dart';
import 'package:object_detection/shared/styles/colors.dart';
import 'package:object_detection/strings/strings.dart';

import 'layouts/animated_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: PRIMARY_SWATCH,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: REGULAR_FONT,

        appBarTheme: AppBarTheme(

            backwardsCompatibility: false,
            titleTextStyle: TextStyle(color: BLACK_COLOR,fontFamily: REGULAR_FONT,fontSize: 15),
          titleSpacing: 50,
          elevation: 0.5,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: MAIN_COLOR,
            ),
        )
      ),
      home: AnimatedSplash(),


    );
  }
}
