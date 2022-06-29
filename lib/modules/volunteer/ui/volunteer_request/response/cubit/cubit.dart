import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/response/cubit/states.dart';

import '../../../../../../models/Request.dart';
import '../../../../../../models/Response.dart';
import '../../../../../../shared/constants.dart';
import '../../../../../../strings/strings.dart';
import '../../../../data/firebase/user_firebase.dart';

class ResponseCubit extends Cubit<VolunteerResponseStates> {
  ResponseCubit() : super(ResponseInitState());

  static ResponseCubit get(context) => BlocProvider.of(context);

  StreamSubscription? requestStream;
  Response? response;

  void speakResponseInformation() async {
    if (response == null) return;
    final FlutterTts flutterTts = FlutterTts();
    flutterTts.setQueueMode(1);
    if (ENG_LANG) {
      await flutterTts.speak("Cool, ${response!.volunteerName} accept your request");
      await flutterTts.speak(
          "Your volunteer will arrive in${(response!.routeData!.duration/60).toInt()} minutes");
      await flutterTts.speak(
          "The distance between you and your volunteer is ${(response!.routeData!.distance/1000).toInt()} kilometers");
      await flutterTts.speak(
          "Tap on the screen to call your volunteer by phone");
    }
    else
      {

        await flutterTts.speak( " سوف يأتي لمساعدتك" + response!.volunteerName);
        await flutterTts.speak(
            "مساعدك سوف يصل بعد ${(response!.routeData!.duration/60).toInt()} دقيقة ");
        await flutterTts.speak(
            "المسافة بينك وبين مساعدك  ${(response!.routeData!.distance/1000).toInt()} كيلومتر ");
        await flutterTts.speak(
            "اضغط علي الشاشة لتقوم بالاتصال بمساعدك");
      }
  }

  void speakResponseWaited() async {
    ENG_LANG? ttsOffline(RESPONSE_WAITED_EN,EN): ttsOffline(RESPONSE_WAITED_AR, AR);
  }

  Future<void> listenOnResponseIfExist() async {
    final preference = await getPreference();
    if (preference.containsKey(PREFERENCE_RESPONSE_KEY)) {
      _listenOnResponse(preference.getString(PREFERENCE_RESPONSE_KEY)!!);
    } else {
      emit(ResponseWaited());
      requestStream = UserFirebase.listenOnMyRequest().listen((docSnapShot) {
        if (docSnapShot.exists && docSnapShot.data() != null) {
          final myRequest = Request.fromJson(docSnapShot.data()!!);
          if (myRequest.state == REQUEST_STATE_ACCEPTED) {
            _listenOnResponse(
                myRequest.blindData.key + "&" + myRequest.volunteerId!);
            requestStream!.cancel();
          }
        }
      });
      requestStream!.onError((err) {
        showToast(err.toString());
      });
    }
  }

  bool firstTime = true;
  StreamSubscription? responseStream;

  void _listenOnResponse(String responseKey) {
    responseStream =
        UserFirebase.listenOnMyResponse(responseKey).listen((doc) async {
      if (doc.exists && doc.data() != null) {
        response = Response.fromJson(doc.data()!);

        emit(ResponseSent());
        if (firstTime) {
          (await getPreference())
              .setString(PREFERENCE_RESPONSE_KEY, responseKey);
          firstTime = false;
        }
      }
    });
  }

  onDispose() {
    requestStream?.cancel();
    responseStream?.cancel();
  }
}
