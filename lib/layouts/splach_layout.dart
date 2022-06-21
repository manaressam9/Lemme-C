import 'package:event/src/event.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:vibration/vibration.dart';
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
    // ttsOffline(SPLACH_INSTRUCTIONS_AR, AR);
    ttsOffline(SPLACH_INSTRUCTIONS_AR, AR, queueMode: 1);
    ttsOffline(SPLACH_INSTRUCTIONS_EN, EN, queueMode: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                color: Color.fromRGBO(55, 57, 59, 0.9),
                child: InkWell(
                  onTap: () {
                    Vibration.vibrate(duration: 200);
                    ttsStop();
                    ENG_LANG = true;
                    navigateAndFinish(context, HomeScreen());
                  },
                  child: Container(
                    child: Center(
                      child: Wrap(
                        children: [
                          Center(child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image(
                              image: AssetImage(GB_FLAG),
                              width: 60,
                              height: 60,
                            ),
                          )),
                          Center(
                              child: Text("English",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ))),
                        ],
                      ),
                    ),
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            Container(
              height: double.infinity,
              width: 3,
              color: Colors.white,
            ),
            Expanded(
              child: Container(
                color: Color.fromRGBO(61, 109, 174, 0.9),
                child: InkWell(
                  onTap: () {
                    Vibration.vibrate(duration: 200);
                    ttsStop();
                    ENG_LANG = false;
                    navigateAndFinish(context, HomeScreen());
                  },
                  child: Container(
                    height: double.infinity,
                    child: Center(
                      child: Wrap(
                        children: [
                          Center(child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image(
                              image: AssetImage(EG_FLAG),
                              width: 60,
                              height: 60,
                            ),
                          )),
                          Center(
                              child: Text("Arabic",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ))),
                        ],
                      ),
                    ),
                  ),
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
    });

    await Future.delayed(Duration(milliseconds: 3000));
    _speakInstructions('Please say one for english, or two for arabic');
  }
}
