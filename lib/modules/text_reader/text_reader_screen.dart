import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/ui/camera_controller.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:path_provider/path_provider.dart';
import '../../layouts/home_screen/home_screen.dart';
import '../../strings/strings.dart';
import '../../utils/tts_utils.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:image/image.dart' as img;


class TextReaderScreen extends StatefulWidget {
  const TextReaderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _cameraControllerPreviewScannerState();
}

class _cameraControllerPreviewScannerState extends State<TextReaderScreen> {
  // CameraController? _cameraController;
  String _scanResults = '';
  final FlutterTts flutterTts = FlutterTts();
  Uint8List? _byte;
  File? imgFile;

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
  // convert Uint8list to File
  Future<File> byteToFile(Uint8List byte) async{
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(_byte!);
    return file;
  }
  // image preprocessed then passed to tesseract for OCR
  imgToText() async{

      XFile rawImg = await CameraControllerFactory.cameraControllers[2]!
          .takePicture();
       imgFile = File(rawImg.path);

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
          pathString: imgFile!.path,
          diameter : 15,
          sigmaColor : 75,
          sigmaSpace : 80,
          borderType : Cv2.BORDER_CONSTANT,
        );
        imgFile =  await byteToFile(_byte!);
        _byte = await Cv2.cvtColor(
            pathFrom: CVPathFrom.GALLERY_CAMERA,
            pathString: imgFile!.path,
            outputType: Cv2.COLOR_RGB2GRAY);
        imgFile =  await byteToFile(_byte!);

        _byte = await Cv2.adaptiveThreshold(
            pathFrom: CVPathFrom.GALLERY_CAMERA,
            pathString: imgFile!.path,
            maxValue: 255,
            adaptiveMethod: 1,
            thresholdType: Cv2.THRESH_BINARY,
            blockSize: 9,
            constantValue: 6);
      } on PlatformException catch (e){ print(e.message);}
      imgFile =  await byteToFile(_byte!);

      String res = await FlutterTesseractOcr.extractText(
          await imgFile!.path,
          language: 'ara+eng',
          args: {
            "psm": "6",
            "preserve_interword_spaces": "1",
          });
      setState(() {
        _scanResults = res;
      });
      showToast( _scanResults);
      print( _scanResults);
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
          onPressed: imgToText
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
