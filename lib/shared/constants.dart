import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:object_detection/modules/volunteer/data/firebase//user_firebase.dart';
import 'package:object_detection/ui/camera_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wavenet/wavenet.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:functional_listener/functional_listener.dart';
import 'package:event/event.dart';

import '../models/User.dart';
import '../ui/camera_view_singleton.dart';

const MAX_HEIGHT = .0;
bool ENG_LANG = false;
const AR = 'ar';
const EN = 'en-US';

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

SharedPreferences? _preferences;

Future<SharedPreferences> getPreference() async {
  if (_preferences == null)
    _preferences = await SharedPreferences.getInstance();
  return _preferences!;
}

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

createControllerafterDisposing(context, onLatestImageAvailable,
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

//stt_function
String text = '';
late _AudioRecognizeState ob;

void setLang(String lang) {
  ob = _AudioRecognizeState(lang);
}

String sttGoogle() {
  print("start");
  ob.streamingRecognize();
  return text;
}

class _AudioRecognizeState {
  final RecorderStream _recorder = RecorderStream();
  bool recognizing = false;
  bool recognizeFinished = false;
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;
  bool start = false;
  int count = 0;
  String language = '';

  @override
  _AudioRecognizeState(String language) {
    this.language = language;
    _recorder.initialize();
  }

  //streaming recognize
  Future<String> streamingRecognize() async {
    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((event) {
      _audioStream!.add(event);
    });

    await _recorder.start();

    recognizing = true;

    final serviceAccount = ServiceAccount.fromString((await rootBundle
        .loadString('assets/poised-team-347818-1953a9db53d2.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream!);

    var responseText = '';

    responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join('\n');

      if (data.results.first.isFinal) {
        responseText += '\n' + currentText;

        text = responseText;
        recognizeFinished = true;
      } else {
        text = responseText + '\n' + currentText;
        recognizeFinished = true;
      }
    });
    print("in" + text);
    return text;
  }

  void stopRecording() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    recognizing = false;
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: language);
}
//language .. 'en_US' or 'ar'

//stt
stt.SpeechToText _speechToText = stt.SpeechToText();
// String textString = "Press The Button";
// bool isListen = false;
// Future<void> listen() async {
//   if (!isListen) {
//     bool avail = await _speechToText.initialize();
//     if (avail) {
//       isListen = true;
//       _speechToText.listen(onResult: (value) {
//         textString = value.recognizedWords;
//         showToast(textString);
//       });
//     }
//   } else {
//     isListen = false;
//     _speechToText.stop();
//   }
// }

//#####################################

//stt_package
bool _speechEnabled = false;
String lastWords = '';
var myEvent = Event<DataTest>();
var result = '';

Future<Event<DataTest>> sttFlutter(String lang) async {
  _speechEnabled = await _speechToText.initialize();
  await _startListening(lang);
/*  myEvent.subscribe((args) {
    if (args != null) {
      result = args.value;
      showToast("input : " + result);
    }
    // print("################################\n"+args.value)
  });*/
  return myEvent;
  // print(lastWords);
}

Future<void> _startListening(String lang) async {
  // print ("start");
  await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 10),
      onSoundLevelChange: null,
      localeId: lang,
      partialResults: false);
}

void stopListening() async {
  // print("stop");
  await _speechToText.stop();
}

void _onSpeechResult(SpeechRecognitionResult result) {
  lastWords = result.recognizedWords;
  DataTest test = DataTest();
  test.value = lastWords;
  myEvent.broadcast(test);
  // print("onSpeech" + lastWords);
}

// An example custom 'argument' class
class DataTest extends EventArgs {
  String value = '';
}

CameraController? cameraController2;

Future<void> createController(
    context, onLatestImageAvailable, int viewIndex) async {
  List<CameraDescription> cameras = await availableCameras();

  if (viewIndex != 2) {
    if (cameraController != null && cameraController!.value.isInitialized) {
      await cameraController!.stopImageStream();
      await cameraController!.startImageStream(onLatestImageAvailable);
    } else {
      cameraController = CameraController(cameras[0], ResolutionPreset.high,
          enableAudio: false);
      await cameraController!.initialize();

// Stream of image passed to [onLatestImageAvailable] callback
      await cameraController!.startImageStream(onLatestImageAvailable);
    }
  } else if (cameraController2 == null ||
      !cameraController2!.value.isInitialized) {
    cameraController2 =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
    await cameraController2!.initialize();
  }
  // cameras[0] for rear-camera

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

void directPhoneCall(String phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}

//tts Google
void tts(String text, String languageCode, String voiceName) async {
  TextToSpeechService _service = TextToSpeechService('ApI_key');
  AudioPlayer _audioPlayer = AudioPlayer();
  //File file = await _service.textToSpeech(text:'اهلا ايمان محمد' , languageCode: "ar-XA" , voiceName: "ar-XA-Wavenet-B", audioEncoding: );
  File file = await _service.textToSpeech(
      text: text,
      languageCode: languageCode,
      voiceName: voiceName,
      audioEncoding: "LINEAR16");
  //(String text , String languageCode , String voiceName , String audioEncoding)
  //('hello, eman mohammed' , "en-US" , "en-US-Wavenet-E")
  //('أهلاً إيمان محمد' , "ar-XA" , "ar-XA-Wavenet-D")
  _audioPlayer.play(file.path, isLocal: true);
}

//tts offline
FlutterTts _flutterTts = FlutterTts();

Future<void> ttsOffline(String text, String language,
    {int queueMode: 0}) async {
  await _flutterTts.setLanguage(language);
  await _flutterTts.setSpeechRate(0.3);
  await _flutterTts.awaitSpeakCompletion(true);
  await _flutterTts.setQueueMode(queueMode);
  await _flutterTts.speak(text);
}

Future<void> ttsFlush() async {
  await _flutterTts.setQueueMode(0);
}

void ttsStop() async {
  await _flutterTts.stop();
}

// Future<void> speak(String tex) async {
//   await _flutterTts.speak(tex);
//   print("speak");
// }
// void stop() async {
//   await _flutterTts.stop();
//   isSpeaking = false;
//   print("stop");
// }

class STT {
  stt.SpeechToText _speech = stt.SpeechToText();
  String textString = "";
  bool isListen = false;
  double confidence = 1.0;
  Function(String? textResult) speechCallback;

  STT(this.speechCallback);

  var myEvent = Event<DataTest>();

  Future<void> listen() async {
    if (!isListen) {
      bool avail = await _speech.initialize();
      if (avail) {
        // setState(() {
        //   isListen = true;
        // });
        isListen = true;

        _speech.listen(onResult: (value) {
          // setState(() {
          //   textString = value.recognizedWords;
          //   if (value.hasConfidenceRating && value.confidence > 0) {
          //     confidence = value.confidence;
          //   }
          // });
          textString = value.recognizedWords;
          DataTest test = DataTest();
          test.value = textString;
          myEvent.broadcast(test);
          myEvent.subscribe(
              (args) => {if (args != null) speechCallback(args.value)});
          // speechCallback(textString);

          // print("################################");
          // print(textString);
          if (value.hasConfidenceRating && value.confidence > 0) {
            confidence = value.confidence;
          }
        });
      }
    } else {
      // setState(() {
      //   isListen = false;
      // });
      isListen = false;
      _speech.stop();
    }
  }

  String get textRecognized => textString;
}
