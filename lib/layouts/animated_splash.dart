import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shared/constants.dart';
import '../strings/strings.dart';
import 'splach_layout.dart';

class AnimatedSplash extends StatelessWidget {
  const AnimatedSplash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(LOGO_IMG),
              width: 0.7*getScreenWidth(context),
              height: 0.4*getScreenHeight(context),
            ),
          ],
        ),
        nextScreen: SplachScreen(),
      backgroundColor: Color.fromRGBO(34, 34, 34, 1),
      splashIconSize: getScreenHeight(context),
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(milliseconds: 900),
    );
  }

}