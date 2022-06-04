import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/modules/object_det/object_detection_screen.dart';
import 'package:object_detection/tflite/classifier.dart';
import 'package:object_detection/tflite/recognition.dart';
import 'package:object_detection/tflite/stats.dart';

import 'package:object_detection/utils/isolate_utils.dart';

import '../shared/constants.dart';
import '../strings/strings.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  Function(List<Recognition>? recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  Function(Stats stats) statsCallback;
  late Function initializeCamera;

  //module name
  String moduleName;

  /// Constructor
  CameraView(this.resultsCallback, this.statsCallback, this.moduleName);


  @override
  _CameraViewState createState() => _CameraViewState(moduleName);
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller

  /// true when inference is ongoing
  late bool predicting;

  /// Instance of [Classifier]
  late Classifier classifier;

  /// Instance of [IsolateUtils]
  late IsolateUtils isolateUtils;

  final String moduleName;

  _CameraViewState(this.moduleName);

  int index = 0;

  @override
  void initState() {
    super.initState();
    index = moduleName == OBJ_MOD_LABEL ? 0 : 1;
    initStateAsync();
  }

  void initStateAsync() async {
    //WidgetsBinding.instance!.addObserver(this);

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    await isolateUtils
        .start(); //send entryPoint function of classifier to isolate

    // Create an instance of classifier to load model and labels
    classifier = Classifier(moduleName);
    // Initially predicting = false
    predicting = false;

    // Camera initialization
    //widget.initializeCamera = initializeCamera;
    initializeCamera();
   // initializeCamera();
  }

  /// Initializes the camera by setting [cameraController]
  Future<void> initializeCamera() async {
    //  await CameraControllerFactory.create(context,index, onLatestImageAvailable);
    await createController(context, onLatestImageAvailable);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }

    return Container(
      height: double.infinity,
      child: AspectRatio(
          aspectRatio: cameraController!.value.aspectRatio,
          child: CameraPreview(cameraController!)),
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier.interpreter != null && classifier.labels != null) {
      // If previous inference has not completed then return
      if (predicting) {
        return;
      }

      if (mounted)
        setState(() {
          predicting = true;
        });

      var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      var isolateData = IsolateData(cameraImage,
          classifier.interpreter!.address, classifier.labels, moduleName);

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      Map<String, dynamic>? inferenceResults = await (inference(isolateData));

      var uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;
      // pass results to HomeView
      widget.resultsCallback(inferenceResults!["recognitions"]);

      // pass stats to HomeView
      widget.statsCallback((inferenceResults["stats"])
        ..totalElapsedTime = uiThreadInferenceElapsedTime);

      // set predicting to false to allow new frames
      if (mounted)
        setState(() {
          predicting = false;
        });
    }
  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>?> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils.sendPort!
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;
    // App state changed before we got the chance to initialize.
    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Free up memory when camera not active
      recreateController();
    }
    super.didChangeAppLifecycleState(state);
  }*/

  recreateController() async {
    await createControllerafterDisposing(context, onLatestImageAvailable);
    cameraController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    if (mounted) cameraController!.stopImageStream();
    super.deactivate();
  }

  @override
  void dispose() {
    if (mounted) cameraController!.stopImageStream();
    super.dispose();
  }
}
