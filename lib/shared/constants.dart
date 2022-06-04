import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:object_detection/modules/volunteer/data/firebase//user_firebase.dart';

import 'package:audioplayer/audioplayer.dart';
import 'package:wavenet/wavenet.dart';

import '../models/User.dart';
import '../ui/camera_view_singleton.dart';
import 'components.dart';

const MAX_HEIGHT = .0;

double getScreenHeight(context) {
  return MediaQuery.of(context).size.height;
}

double getScreenWidth(context) {
  return MediaQuery.of(context).size.width;
}

showToast(String msg, {Toast duration = Toast.LENGTH_SHORT}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: duration,
    backgroundColor: Colors.transparent,
    textColor: Colors.red,
    fontSize: 15,
    gravity: ToastGravity.SNACKBAR,
  );
}

void navigateAndFinish(BuildContext context, Widget screen) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => screen),
    (route) => false, //if you want to disable back feature set to false
  );
}

Future navigate(BuildContext context, Widget screen) async {
  return await Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));
}

// validators
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Phone is required!';
  if (value.length != 11) return 'Invalid phone !';
  String firstPart = value.substring(0, 3);
  if ((firstPart != '010' &&
      firstPart != '011' &&
      firstPart != '012' &&
      firstPart != '015')) return 'Invalid phone !';
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required!';
  if (!EmailValidator.validate(value)) return 'Invalid email !';

  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required !';
  if (value.length < 8) return 'Password is very weak !';
  return null;
}

String handleError(String errCode) {
  String errMessage = '';
  switch (errCode) {
    case 'ERROR_EMAIL_ALREADY_IN_USE':
      errMessage =
          "This e-mail address is already in use, please use a different e-mail address.";
      break;
    case 'ERROR_INVALID_EMAIL':
      errMessage = "The email address is badly formatted.";
      break;
    case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
      errMessage =
          "The e-mail address has been registered in the system before. ";
      break;
    case 'user-not-found':
      errMessage = 'No user found for that email. ';
      break;

    case 'wrong-password':
      errMessage = 'Wrong password provided for that user. ';
      break;
    case 'requires-recent-login':
      errMessage = 'This process is sensitive, please login again before.';
      break;
    default:
      errMessage = '$errCode';
  }
  return errMessage;
}

final FirebaseFirestore myFireStore = FirebaseFirestore.instance;

final FirebaseStorage myStorage = FirebaseStorage.instance;

UserModel generalUser = UserModel.fromUser();

// date handle
String handleDate(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  final aDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  String specialDate = '';
  if (aDate == today) {
    if (isJustNow(aDate, now))
      specialDate = 'Just now';
    else
      specialDate = 'today';
  } else if (aDate == yesterday) {
    specialDate = 'yesterday';
  } else {
    if (aDate.year == now.year)
      return _format(dateTime, true, false);
    else
      return _format(dateTime, true, true);
  }
  return specialDate != 'Just now'
      ? '$specialDate ${_format(dateTime, false, false)}'
      : specialDate;
}

bool isJustNow(DateTime aDate, DateTime now) {
  return (aDate.hour == now.hour && (now.minute - aDate.minute) <= 1);
}

String handleTodayHoursOrMinutesOrjustNow(DateTime aDate, DateTime now) {
  int hours = now.hour - aDate.hour;
  int minutes = now.minute - aDate.minute;
  if (minutes < 0) hours -= 1;
  String timeResult = '';
  String label = '';
  if (hours >= 1) {
    label = hours > 1 ? 'hours' : 'hour';
    timeResult = '$hours $label';
  } else if (minutes >= 1) {
    label = minutes > 1 ? 'minutes' : 'minute';
    timeResult = '$minutes $label';
  } else
    timeResult = 'Just now';
  return timeResult;
}

String _format(DateTime dateTime, bool totalDate, bool yearExist) {
  if (totalDate && !yearExist)
    return DateFormat('MMMM dd').format(dateTime) +
        ' at ' +
        DateFormat.jm().format(dateTime);
  else if (totalDate && yearExist)
    return DateFormat('MMMM dd, yyyy').format(dateTime) +
        ' at ' +
        DateFormat.jm().format(dateTime);
  else
    return 'at ' + DateFormat.jm().format(dateTime);
}

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return (result.isNotEmpty && result[0].rawAddress.isNotEmpty);
  } on SocketException catch (_) {
    return false;
  }
}

Future<UserModel> getCurrentUser() async {
  UserModel? currentUser;
  if (currentUser == null) {
    Map<String, dynamic>? data = (await UserFirebase.getUser()).data();
    if (data != null && data.isNotEmpty) {
      currentUser = UserModel.fromJson(data);
    }
  }
  return currentUser!;
}

const OBJECT_IMAGE_SIZE = 640;
const CURR_IMAGE_SIZE = 512;

//late List<CameraDescription> cameras;

/// Controller
CameraController? cameraController;

createController(context, onLatestImageAvailable,
    {CameraDescription? description}) async {
   if (cameraController != null && cameraController!.value.isInitialized) {
    await cameraController!.startImageStream(onLatestImageAvailable);
    return;
  }

  List<CameraDescription> cameras = await availableCameras();
  // cameras[0] for rear-camera

  cameraController =
      CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
  await cameraController!.initialize();

// Stream of image passed to [onLatestImageAvailable] callback
  await cameraController!.startImageStream(onLatestImageAvailable);

  /// previewSize is size of each image frame captured by controller
  ///
  /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
  Size previewSize = cameraController!.value.previewSize!;

  /// previewSize is size of raw input image to the model
  CameraViewSingleton.inputImageSize = previewSize;

// the display width of image on screen is
// same as screenWidth while maintaining the aspectRatio
  Size screenSize = MediaQuery.of(context).size;
  CameraViewSingleton.screenSize = screenSize;
  CameraViewSingleton.ratio = screenSize.width / previewSize.height;
  ;
}

//tts_function
void tts (String text , String languageCode , String voiceName){
  TextToSpeechService _service = TextToSpeechService('API_KEY');
  AudioPlayer _audioPlayer = AudioPlayer();
  //File file = await _service.textToSpeech(text:'اهلا ايمان محمد' , languageCode: "ar-XA" , voiceName: "ar-XA-Wavenet-B", audioEncoding: );
  File file = await _service.textToSpeech(text:text , languageCode: languageCode, voiceName: voiceName , audioEncoding: "LINEAR16");
  //(String text , String languageCode , String voiceName , String audioEncoding)
  _audioPlayer.play(file.path, isLocal: true );  
}

