import 'package:event/src/event.dart';
import 'package:event/src/eventargs.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../shared/styles/colors.dart';
import '../utils/stt_utils.dart';

class SplachScreen extends StatefulWidget {
  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen> {
  @override
  void initState() {
    // TODO: implement initState
    /*  _speakInstructions(
        'Welcome in blind assistant app, please say one for english, or two for arabic');*/
    ttsOffline(SPLACH_INSTRUCTIONS, EN);
    ttsOffline(SPLACH_INSTRUCTIONS2, EN);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(APP_NAME),
        ),
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  ENG_LANG = true;
                  navigateAndFinish(context, HomeScreen());
                },
                child: Container(
                  child: Center(
                      child: Text(
                    "English",
                    style: TextStyle(fontSize: 25),
                  )),
                  height: double.infinity,
                ),
              ),
            ),
            Container(
              height: double.infinity,
              width: 1,
              color: GREY_COLOR,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  ENG_LANG = false;
                  navigateAndFinish(context, HomeScreen());
                },
                child: Container(
                  height: double.infinity,
                  child: Center(
                      child: Text("Arabic", style: TextStyle(fontSize: 25))),
                ),
              ),
            )
          ],
        ));
  }

  Future<void> _speakInstructions(String text) async {
    await ttsOffline(text, EN);
    Event<DataTest> myEvent = await mySTT.listen(EN);
    myEvent.subscribe((args) async {
      if (args != null) {
        if (args.value == '1') {
          ENG_LANG = true;
          navigateAndFinish(context, HomeScreen());
        } else if (args.value == '2') {
          navigateAndFinish(context, HomeScreen());
        }
      }
      // print("################################\n"+args.value)
    });

    await Future.delayed(Duration(milliseconds: 3000));
    _speakInstructions('Please say one for english, or two for arabic');
  }
}
