// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:object_detection/shared/constants.dart';
import '../../ui/camera_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/ui/camera_controller.dart';
import '../../layouts/home_screen/home_screen.dart';
import '../../strings/strings.dart';
import '../../utils/image_utils.dart';
import '../../utils/tts_utils.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';



class TextReaderScreen extends StatefulWidget {
  const TextReaderScreen({Key? key}) : super(key: key);

  @override
  _cameraControllerPreviewScannerState createState() => _cameraControllerPreviewScannerState();
}

class _cameraControllerPreviewScannerState extends State<TextReaderScreen> {
  String _scanResults = '';
  bool _isDetecting = false;
  bool tapped = false;
  late XFile _PickedImage;
  File? file ;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    TTS.speak(Text_MOD_LABEL);
    HomeScreen.cubit.changeSelectedIndex(2);
    _initializeCamera();
  }
  Future<void> _initializeCamera() async {
    await CameraControllerFactory.create (context, 2, (CameraImage frame) async{
      if (tapped = true){
        tapped = false;
      imageLib.Image? Imgframe = ImageUtils.convertCameraImage(frame);
      if(Imgframe != null){
      var bytes = Imgframe!.getBytes();
      String tempPath = (await getTemporaryDirectory()).path;
      setState(() {
       file = File('$tempPath/temp.png');
      });
      await file!.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));}
    } });
   // await CameraControllerFactory.create(context, 3, (frame){} );
  /*  setState(() {

    });*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(onTap: () async{
        tapped = true;
        //_PickedImage = await CameraControllerFactory.cameraControllers[3]!.takePicture();
       // showToast(_PickedImage.path);
        if(file != null){
       _scanResults  = await FlutterTesseractOcr.extractText(file!.path, language: 'ara+eng', args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        });}
        showToast( _scanResults);
        print( _scanResults);
      },
        child: new Container(
          height: double.infinity,
          child:  CameraControllerFactory.cameraControllers[2] != null ? AspectRatio(
            aspectRatio: CameraControllerFactory.cameraControllers[2]!.value.aspectRatio,
            child: new CameraPreview(CameraControllerFactory.cameraControllers[2]!),
          ): Container()
        ),
      ),
    );
  }

  /*@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }*/
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
