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
import 'package:vibration/vibration.dart';
import '../../layouts/home_screen/home_screen.dart';
import '../../strings/strings.dart';
import '../../ui/camera_controller.dart';
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
  late int pauseModule;
  RegExp arExp = RegExp("[\u0600-\u06FF]+");
  RegExp enExp = RegExp("[a-zA-Z]+");


  @override
  void initState() {
    super.initState();
    ENG_LANG? ttsOffline(Text_MOD_LABEL,EN): ttsOffline(Text_MOD_LABEL_AR, AR);
    pauseModule = 0;
    // TTS.speak(Text_MOD_LABEL);
    HomeScreen.cubit.changeSelectedIndex(2);
    _initializeCamera();
  }

  late CameraDescription description;

  _initializeCamera() async {
    await CameraControllerFactory.create(context, 2);
    await CameraControllerFactory.cameraControllers[2]!.setFocusMode(FocusMode.auto);
    await CameraControllerFactory.cameraControllers[2]!.setFlashMode(FlashMode.off);

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
    //cameraController2!.dispose();
//    CameraControllerFactory.cameraControllers[2]!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onLongPress: () async {
          Vibration.vibrate(duration: 200);
          setState(() {
            pauseModule = 0;
          });
          XFile rawImg = await CameraControllerFactory.cameraControllers[2]!.takePicture();
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
                "psm": "11",
                "preserve_interword_spaces": "3",
              });
          setState(() {
            res = res.replaceAll(RegExp("\\s+")," ").replaceAll(RegExp("[!-\/:-@\[-`\{-~]"),"");
            _scanResults = res;
          });
          int arCount = arExp.allMatches(_scanResults).length;
          int enCount = enExp.allMatches(_scanResults).length;
          showToast("ar ${arCount}");
          showToast("en ${enCount}");
          // showToast(_scanResults);
          print(_scanResults);
          enCount>arCount? await ttsOffline(_scanResults, EN): await ttsOffline(_scanResults, AR);

        },

        onDoubleTap: () {
          Vibration.vibrate(duration: 200);
          ttsStop();
          ENG_LANG? ttsOffline("Paused",EN): ttsOffline("توقف", AR);
          setState(() {
            pauseModule = 0;
          });

          // setState(() {
          //   pauseModule = (pauseModule+1)%2;
          // });
          // if (pauseModule==1){
          //   ENG_LANG? ttsOffline("Paused",EN): ttsOffline("توقف", AR);
          //   setState(() {});
          // }
          // else{
          //   ENG_LANG? ttsOffline("Start", EN): ttsOffline("بدأ", AR);
          // }
        },
        child: Container(
          constraints: const BoxConstraints.expand(),
          child: (CameraControllerFactory.cameraControllers[2] != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CameraPreview(
                      CameraControllerFactory.cameraControllers[2]!))
              : Container(),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //     child: Icon(Icons.add_a_photo_outlined),
      //     onPressed: () async {
      //       XFile rawImg = await CameraControllerFactory.cameraControllers[2]!
      //           .takePicture();
      //       File imgFile = File(rawImg.path);
      //
      //       //resize the imgFile
      //       final image = img.decodeImage(imgFile!.readAsBytesSync())!;
      //       final thumbnail = img.copyResize(image, width: 1080);
      //       final tempDir = await getTemporaryDirectory();
      //       imgFile = await File('${tempDir.path}/thumb.png').create();
      //       imgFile!.writeAsBytesSync(img.encodePng(thumbnail));
      //       //preprocessing pipeline
      //       try{
      //         /*_byte = await Cv2.adaptiveThreshold(
      //       pathFrom: CVPathFrom.GALLERY_CAMERA,
      //       pathString: await imgFile!.path,
      //       maxValue: 255,
      //       adaptiveMethod: 1,
      //       thresholdType: Cv2.THRESH_BINARY,
      //       blockSize: 11,
      //       constantValue: 12);*/
      //         _byte = await Cv2.bilateralFilter(
      //           pathFrom: CVPathFrom.GALLERY_CAMERA,
      //           pathString: await imgFile!.path,
      //           diameter : 15,
      //           sigmaColor : 75,
      //           sigmaSpace : 80,
      //           borderType : Cv2.BORDER_CONSTANT,
      //         );
      //         imgFile =  await byteToFile(_byte!);
      //         _byte = await Cv2.cvtColor(
      //             pathFrom: CVPathFrom.GALLERY_CAMERA,
      //             pathString: await imgFile!.path,
      //             outputType: Cv2.COLOR_RGB2GRAY
      //         );
      //         imgFile =  await byteToFile(_byte!);
      //
      //         _byte = await Cv2.adaptiveThreshold(
      //             pathFrom: CVPathFrom.GALLERY_CAMERA,
      //             pathString: await imgFile!.path,
      //             maxValue: 255,
      //             adaptiveMethod: 1,
      //             thresholdType: Cv2.THRESH_BINARY,
      //             blockSize: 9,
      //             constantValue: 6);
      //       } on PlatformException catch (e){ print(e.message);}
      //       imgFile =  await byteToFile(_byte!);
      //       String res = await FlutterTesseractOcr.extractText(imgFile.path,
      //           language: 'ara+eng',
      //           args: {
      //             "psm": "4",
      //             "preserve_interword_spaces": "1",
      //           });
      //       setState(() {
      //         _scanResults = res;
      //       });
      //       showToast(_scanResults);
      //       print(_scanResults);
      //     }),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}