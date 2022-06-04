import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:object_detection/tflite/recognition.dart';
import 'package:object_detection/tflite/stats.dart';
import 'package:object_detection/ui/box_widget.dart';
import 'package:object_detection/utils/tts_utils.dart';

import '../../ui/camera_view.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class ObjectDetection extends StatefulWidget {
  ObjectDetection({Key? key}) : super(key: key);
  //static CameraView? cameraView;

  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection>
    with WidgetsBindingObserver {
  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    TTS.speak(OBJ_MOD_LABEL);
    HomeScreen.cubit.changeSelectedIndex(0);
    //ObjectDetection.cameraView = CameraView(resultsCallback, statsCallback, OBJ_MOD_LABEL);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // cameraController!.dispose();
    super.dispose();
  }

  /* @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Camera View
          ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CameraView(resultsCallback, statsCallback, OBJ_MOD_LABEL)),
          // Bounding boxes
          boundingBoxes(results),

          /* (stats != null)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      StatsRow('Inference time:', '${stats!.inferenceTime} ms'),
                      StatsRow('Total prediction time:',
                          '${stats!.totalElapsedTime} ms'),
                      StatsRow('Pre-processing time:',
                          '${stats!.preProcessingTime} ms'),
                      StatsRow('Frame',
                          '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}'),
                    ],
                  ),
                )
              : Container()*/
        ],
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }

    flutterTts.awaitSpeakCompletion(true);
    results.forEach((element) async {
      await flutterTts.speak(element.label);
      //    await _service.speak(element.label, true);
    });

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
    if (mounted)
      setState(() {
        this.results = results;
      });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    if (mounted)
      setState(() {
        this.stats = stats;
      });
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
