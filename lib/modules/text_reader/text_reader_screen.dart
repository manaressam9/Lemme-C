import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/ui/camera_controller.dart';
import '../../layouts/home_screen/home_screen.dart';
import '../../strings/strings.dart';
import '../../utils/tts_utils.dart';

class TextReaderScreen extends StatefulWidget {
  const TextReaderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _cameraControllerPreviewScannerState();
}

//  CameraController? _cameraController;
class _cameraControllerPreviewScannerState extends State<TextReaderScreen> {
  // CameraController? _cameraController;
  String _scanResults = '';
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    TTS.speak(Text_MOD_LABEL);
    HomeScreen.cubit.changeSelectedIndex(2);
    _initializeCamera();
  }

  late CameraDescription description;

  _initializeCamera() async {
    //await CameraControllerFactory.create(context, 2);
    await cameraController!.setFlashMode(FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: (cameraController!= null)

      ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CameraPreview(
                    cameraController!))
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo_outlined),
          onPressed: () async {
            XFile rawImg = await cameraController!.takePicture();
            File imgFile = File(rawImg.path);
            String res = await FlutterTesseractOcr.extractText(imgFile.path,
                language: 'ara+eng',
                args: {
                  "psm": "4",
                  "preserve_interword_spaces": "1",
                });
            setState(() {
              _scanResults = res;
            });
            showToast(_scanResults);
            print(_scanResults);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
