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

  Future<void> _initializeCamera() async {
    await CameraControllerFactory.create(context, 2);
    await CameraControllerFactory.cameraControllers[2]!.setFlashMode(FlashMode.off);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: (CameraControllerFactory.cameraControllers[2] != null)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CameraPreview(
                    CameraControllerFactory.cameraControllers[2]!))
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo_outlined),
          onPressed: () async {
            XFile rawImg = await CameraControllerFactory.cameraControllers[2]!
                .takePicture();
            File imgFile = File(rawImg.path);
            String res = await FlutterTesseractOcr.extractText(
                imgFile.path,
                language: 'ara+eng',
                args: {
                  "psm": "4",
                  "preserve_interword_spaces": "1",
                });
            setState(() {
              _scanResults = res;
            });
            showToast( _scanResults);
            print( _scanResults);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
