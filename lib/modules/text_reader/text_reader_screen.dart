import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
  Uint8List? _byte;

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

  // convert Uint8list to File
  Future<File> byteToFile(Uint8List byte) async{
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(_byte!);
    return file;
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

            //resize the imgFile
            final image = img.decodeImage(imgFile!.readAsBytesSync())!;
            final thumbnail = img.copyResize(image, width: 1080);
            final tempDir = await getTemporaryDirectory();
            imgFile = await File('${tempDir.path}/thumb.png').create();
            imgFile!.writeAsBytesSync(img.encodePng(thumbnail));
            //preprocessing pipeline
            try{
              /*_byte = await Cv2.adaptiveThreshold(
            pathFrom: CVPathFrom.GALLERY_CAMERA,
            pathString: await imgFile!.path,
            maxValue: 255,
            adaptiveMethod: 1,
            thresholdType: Cv2.THRESH_BINARY,
            blockSize: 11,
            constantValue: 12);*/
              _byte = await Cv2.bilateralFilter(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: await imgFile!.path,
                diameter : 15,
                sigmaColor : 75,
                sigmaSpace : 80,
                borderType : Cv2.BORDER_CONSTANT,
              );
              imgFile =  await byteToFile(_byte!);
              _byte = await Cv2.cvtColor(
                  pathFrom: CVPathFrom.GALLERY_CAMERA,
                  pathString: await imgFile!.path,
                  outputType: Cv2.COLOR_RGB2GRAY
              );
              imgFile =  await byteToFile(_byte!);

              _byte = await Cv2.adaptiveThreshold(
                  pathFrom: CVPathFrom.GALLERY_CAMERA,
                  pathString: await imgFile!.path,
                  maxValue: 255,
                  adaptiveMethod: 1,
                  thresholdType: Cv2.THRESH_BINARY,
                  blockSize: 9,
                  constantValue: 6);
            } on PlatformException catch (e){ print(e.message);}
            imgFile =  await byteToFile(_byte!);
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