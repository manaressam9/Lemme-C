import 'package:flutter/material.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:object_detection/tflite/recognition.dart';
import 'package:object_detection/tflite/stats.dart';
import 'package:object_detection/ui/box_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

import '../../ui/camera_view.dart';
import '../../utils/tts_utils.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class CurrencyCounter extends StatefulWidget {
  static CameraView? cameraView;

  const CurrencyCounter({Key? key}) : super(key: key);

  @override
  _CurrencyCounterState createState() => _CurrencyCounterState();
}

class _CurrencyCounterState extends State<CurrencyCounter>
    with WidgetsBindingObserver {
  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  /// Pause module controller
  late int pauseModule;

  get infrenceResults => null;
  // final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    pauseModule = 0;
    // TTS.speak(CURR_MOD_LABEL);
    ENG_LANG? ttsOffline(CURR_MOD_LABEL,EN): ttsOffline(CURR_MOD_LABEL_AR, AR);
    HomeScreen.cubit.changeSelectedIndex(1);
    CurrencyCounter.cameraView = CameraView(resultsCallback, statsCallback, CURR_MOD_LABEL,pauseModule);
  }

/*  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController!.dispose();
    }
    super.didChangeAppLifecycleState(state);
  }*/

/*  void dispose() {
    // TODO: implement dispose
    cameraController!.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: (){
          Vibration.vibrate(duration: 200);
          ttsStop();
          setState(() {
            pauseModule = (pauseModule+1)%2;
            results = null;
          });
          if (pauseModule==1){
            ENG_LANG? ttsOffline("Paused",EN): ttsOffline("توقف", AR);
          }
          else{
            ENG_LANG? ttsOffline("Start", EN): ttsOffline("بدأ", AR);
          }
        },
        child: Stack(
          children: <Widget>[
            // Camera View

            ClipRRect(
                borderRadius: BorderRadius.circular(15),

                child:  CurrencyCounter.cameraView),
            // Bounding boxes
            boundingBoxes(results),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(pauseModule==0?Icons.pause_sharp:Icons.play_arrow_sharp),
      //   onPressed: (){
      //     setState(() {
      //       pauseModule = (pauseModule+1)%2;
      //     });
      //     print(pauseModule==0?"Paused":"Play");
      //   },
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition>? results) {
    if (this.pauseModule ==1 || results == null) {
      setState(() {
        this.results = null;
      });
      return Container();
    }
    // final FlutterTts flutterTts = FlutterTts();
    // flutterTts.awaitSpeakCompletion(true);
    results.forEach((element) async {
      String currency = element.label.replaceFirst("Egp", " Pounds");
      // await flutterTts.speak(currency);

    });
    //Counting Notes and Calc AVG Score
    int totalNotes = 0;
    double avgScore = 0;
    results.forEach((element) {
      totalNotes += int.parse(element.label.substring(0,element.label.length-3));
      avgScore += element.score;
    });
    avgScore /= results.length;
    ENG_LANG?ttsOffline(totalNotes.toString() +" Pounds" , EN):ttsOffline(totalNotes.toString()+" جنيه", AR);
    // flutterTts.speak(totalNotes.toString() + " Pounds");


    // results.forEach((element) async {
    //   String currency = element.label.replaceFirst("Egp", " Pounds");
    //   await flutterTts.speak(currency);
    // });
    return Stack(
      children: results
          .map((e) => BoxWidget(
                result: e,
              ))
          .toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition>? results) {
    if(mounted){
      setState(() {
        this.results = results;
      });
    }
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    if(mounted){
      setState(() {
        this.stats = stats;
      });
    }
  }

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);


}

/// Row for one Stats field
class StatsRow extends StatelessWidget {
  final String left;
  final String right;

  StatsRow(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(foreground: Paint()..color = Colors.white),
          ),
          Text(
            right,
            style: TextStyle(foreground: Paint()..color = Colors.white),
          ),
        ],
      ),
    );
  }
}
