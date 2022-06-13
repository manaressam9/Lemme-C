import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

import 'camera_view_singleton.dart';

class CameraControllerFactory {
  static List<CameraController?> cameraControllers = [null, null, null];

  static late List<CameraDescription> cameras;

  static Future<CameraController?> create(
      BuildContext context, int index,{onLatestImageAvailable}) async {
    cameras = await availableCameras();

    cameraControllers[index] =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
    //  }
    await cameraControllers[index]!.initialize();

    /// Stream of image passed to [onLatestImageAvailable] callback to CurrencyScreen and ObjScreen
    if (index != 2){
      await cameraControllers[index]!.startImageStream(onLatestImageAvailable);
    }

    /// previewSize is size of each image frame captured by controller
    ///
    /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
    Size previewSize = cameraControllers[index]!.value.previewSize!;

    /// previewSize is size of raw input image to the model
    CameraViewSingleton.inputImageSize = previewSize;

// the display width of image on screen is
// same as screenWidth while maintaining the aspectRatio
    Size screenSize = MediaQuery.of(context).size;
    CameraViewSingleton.screenSize = screenSize;
    CameraViewSingleton.ratio = screenSize.width / previewSize.height;

    return cameraControllers[index];
  }


}
