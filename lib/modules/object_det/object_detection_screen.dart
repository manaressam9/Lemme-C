import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/strings/strings.dart';
import 'package:object_detection/tflite/recognition.dart';
import 'package:object_detection/tflite/stats.dart';
import 'package:object_detection/ui/box_widget.dart';
import 'package:object_detection/ui/camera_view_singleton.dart';

import '../../ui/camera_view.dart';
import '../currency_counter/currency_counter_screen.dart';

/// [HomeView] stacks [CameraView] and [BoxWidget]s with bottom sheet for stats
class ObjectDetection extends StatefulWidget {
  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context){
    return Scaffold(
     
      body: Stack(
        children: <Widget>[
          // Camera View

          CameraView(resultsCallback, statsCallback,OBJ_MOD_LABEL),

          // Bounding boxes
          boundingBoxes(results),

          (stats != null)
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  StatsRow('Inference time:',
                      '${stats!.inferenceTime} ms'),
                  StatsRow('Total prediction time:',
                      '${stats!.totalElapsedTime} ms'),
                  StatsRow('Pre-processing time:',
                      '${stats!.preProcessingTime} ms'),
                  StatsRow('Frame',
                      '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}'),
                ],
              ),
            )
          : Container()

        ],
      ),

    );
  }





  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition>? results)  {
    if (results == null) {
      return Container();
    }

    final FlutterTts flutterTts=FlutterTts();
    results.forEach((element) async {
      await flutterTts.setQueueMode(1);
      await flutterTts.speak(element.label);
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
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
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
        children: [Text(
        left,
        style: TextStyle(
            foreground: Paint()..color = Colors.white
        ),
      ), Text(
          right,
          style: TextStyle(
              foreground: Paint()..color = Colors.white
          ),
        ),],
      ),
    );
  }
}
