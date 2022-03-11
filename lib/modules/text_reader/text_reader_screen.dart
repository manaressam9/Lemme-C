// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/ui/camera_controller.dart';

import '../../layouts/home_screen/home_screen.dart';
import '../../shared/styles/colors.dart';
import '../../strings/strings.dart';
import '../../utils/tts_utils.dart';
import 'detector_painters.dart';
import 'scanner_utils.dart';

class TextReaderScreen extends StatefulWidget {
  const TextReaderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _cameraControllerPreviewScannerState();
}

class _cameraControllerPreviewScannerState extends State<TextReaderScreen> {
  dynamic _scanResults;
  Detector? _currentDetector = Detector.text;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  final TextRecognizer _recognizer = GoogleVision.instance.textRecognizer();

//  CameraController? _cameraController;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    TTS.speak(Text_MOD_LABEL);
    HomeScreen.cubit.changeSelectedIndex(2);
    _initializeCamera();
  }

  late CameraDescription description;

  Future<void> _initializeCamera() async {
    description = await ScannerUtils.getCamera(_direction);
    await CameraControllerFactory.create(context, 2, onLatestImageAvailable);

  }

  onLatestImageAvailable(CameraImage image) {
    if (_isDetecting) return;

    _isDetecting = true;
    ScannerUtils.detect(
      image: image,
      detectInImage: _recognizer.processImage,
      imageRotation: description.sensorOrientation,
    ).then(
      (dynamic results) {
        if (_currentDetector == null) return;
        setState(() {
          _scanResults = results;
        });
      },
    ).whenComplete(() => Future.delayed(
        Duration(
          milliseconds: 100,
        ),
        () => {_isDetecting = false}));
  }

  Widget _buildResults() {
    if (_scanResults == null ||
        CameraControllerFactory.cameraControllers[2] == null ||
        !CameraControllerFactory.cameraControllers[2]!.value.isInitialized) {
      return Container();
    }

    CustomPainter painter;

    final Size imageSize = Size(
      CameraControllerFactory.cameraControllers[2]!.value.previewSize!.height,
      CameraControllerFactory.cameraControllers[2]!.value.previewSize!.width,
    );

    if (_scanResults is! VisionText) return Container();
    painter = TextDetectorPainter(imageSize, _scanResults);

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: /*_cameraController == null
          ? const Center(
        child: Text(
          'Initializing Camera...',
          style: TextStyle(
            color: GREY_COLOR,
            fontSize: 30,
          ),
        ),
      )
          :*/
          Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (CameraControllerFactory.cameraControllers[2] != null)
            ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CameraPreview(
                    CameraControllerFactory.cameraControllers[2]!)),
          _buildResults(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildImage(),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _recognizer.close();
    super.dispose();
  }
/* @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
     //   _cameraController!.stopImageStream();
        break;
      case AppLifecycleState.resumed:
      */ /*  if (!_cameraController!.value.isStreamingImages) {
          await _cameraController!.startImageStream(onLatestImageAvailable);
        }*/ /*
        break;
      default:
    }
  }

  @override
  void dispose() {
     // _cameraController!.dispose().then((_) {
   // });
    _recognizer.close();
    _currentDetector = null;
    super.dispose();
  }*/

}
