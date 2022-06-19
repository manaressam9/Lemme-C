import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/models/Request.dart';
import 'package:object_detection/models/Response.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/cubit/states.dart';

import '../../../../../models/User.dart';
import '../../../../../shared/constants.dart';
import '../../../../../strings/strings.dart';
import '../../../../../utils/tts_utils.dart';
import '../../../data/firebase/user_firebase.dart';
import '../../../data/location/location_api.dart';
import '../volunteer_request_screen.dart';

class VolunteerRequestCubit extends Cubit<VolunteerRequestStates> {
  VolunteerRequestCubit() : super(RegisterInitState());

  static VolunteerRequestCubit get(context) => BlocProvider.of(context);

  onVolunteerInit() {
    // TTS.speak(VOLUNTEER_MOD_LABEL);
    ENG_LANG? ttsOffline(VOLUNTEER_MOD_LABEL,EN): ttsOffline(VOLUNTEER_MOD_LABEL_AR, AR);
    HomeScreen.cubit.changeSelectedIndex(3);
    VolunteerRequestScreen.setState = () {
      emit(RegisterInitState());
    };
  }

  onRequestInit (){
    ENG_LANG? ttsOffline(REQUEST_INSTRUCTIONS,EN): ttsOffline(REQUEST_INSTRUCTIONS_AR, AR);
  }

  String loginOrReg = 'REGISTER';

  void switchRegLogin() {
    loginOrReg = (loginOrReg == 'REGISTER') ? 'LOGIN' : 'REGISTER';
    emit(LoginRegSwitch());
  }

  backStage(VolunteerRequestStates stageState) {
    emit(RegisterInitState());
  }

  String verificationId = '',
      smsCode = '',
      nationalId = '',
      fullName = '',
      phone = '';

  Future<void> sendPhoneOtp(int fromRegisterOrVerifyScreen) async {
    emit(PhoneVerificationLoading());
    try {
      await UserFirebase.signIn(
          phone: phone,
          onAutoVerification: onAutoVerification,
          onCodeSent: onCodeSentHandler,
          onVerificationFailed: onVerificationFailed,
          onAutoVerificationTimeOut: onCodeAutoRetrievalTimeout);
      if (fromRegisterOrVerifyScreen != 0) //request from registerScreen
        emit(PhoneCodeResentState()); //request from phone verification screen
    } on FirebaseAuthException catch (err) {
      String errMessage = handleError(err.code);
      emit(RegisterErrorState(errMessage));
    }
  }

  // source screen parameter:
  // 0 -> RegisterScreen
  // 1 -> LoginScreen
  Future<bool> isPhoneNumberExist({required int sourceScreen}) async {
    emit(PhoneFilteringLoadingState());
    bool isExist = await UserFirebase.isPhoneNumberExist(phone);
    if (isExist) {
      if (sourceScreen == 0) // if source screen is register
        emit(RegisterFirstStageFailedState());
      else
        emit(LoginFirstStageCompletedState()); // if source screen is login
    } else {
      if (sourceScreen == 0) // if source screen is register
        emit(RegisterFirstStageCompletedState());
      else
        emit(LoginFirstStageFailedState());
    }
    return isExist;
  }

  logIn({PhoneAuthCredential? phoneAuthCredential}) async {
    try {
      emit(PhoneVerificationLoading());
      UserCredential credential;
      if (phoneAuthCredential != null) {
        credential =
            await UserFirebase.signInWithCredential(phoneAuthCredential);
      } else {
        credential = await UserFirebase.createCredentialAndSignIn(
            verificationId, smsCode);
      }
      emit(VerificationSuccessState());
    } on FirebaseAuthException catch (err) {
      emit(RegisterErrorState(err.message.toString()));
    }
  }

  signUp({PhoneAuthCredential? phoneAuthCredential}) async {
    try {
      emit(PhoneVerificationLoading());
      UserCredential credential;
      if (phoneAuthCredential != null) {
        credential =
            await UserFirebase.signInWithCredential(phoneAuthCredential);
      } else {
        credential = await UserFirebase.createCredentialAndSignIn(
            verificationId, smsCode);
      }

      UserModel user = UserModel(
          nationalId: nationalId,
          fullName: fullName,
          phone: phone,
          key: credential.user!.uid);
      try {
        await UserFirebase.storeUserData(user: user, uId: credential.user!.uid);
        emit(VerificationSuccessState());
      } catch (err) {
        credential.user!.delete();
        emit(RegisterErrorState('Check internet connection!'));
      }
    } on FirebaseAuthException catch (err) {
      emit(RegisterErrorState(err.message.toString()));
    }
  }

  onAutoVerification(PhoneAuthCredential phoneAuthCredential) async {
    this.smsCode = phoneAuthCredential.smsCode ?? "";
    emit(PhoneAutoVerification());
    if (loginOrReg == 'REGISTER')
      await signUp(phoneAuthCredential: phoneAuthCredential);
    else
      await logIn(phoneAuthCredential: phoneAuthCredential);
  }

  onCodeAutoRetrievalTimeout(String verificationId) {
    emit(AutoVerificationTimeOut());
  }

  onCodeSentHandler(String verificationId, int? resendToken) {
    emit(PhoneCodeSentState());
    this.verificationId = verificationId;
  }

  onVerificationFailed(FirebaseAuthException e) {
    //emit(RegisterErrorState(errMessage));
    if (e.code == 'invalid-phone-number') {
      showToast('The provided phone number is not valid.');
    } else
      showToast(e.message.toString());
    emit(VerificationFailed(e.message.toString()));
  }

  IconData idSuffixIcon = Icons.remove_red_eye;
  bool idSecure = true;

  changeIDVisibility() {
    idSecure = !idSecure;
    idSuffixIcon = idSecure ? Icons.remove_red_eye : Icons.visibility_off;
    emit(RegisterSecureVisibilityChangeState());
  }

  // volunteer screen
  onVolunteerRequest(VolunteerRequestCubit cubit) async {
    emit(RequestLoading());
    try {
      await LocationApi.sendRealTimeLocationUpdates(cubit);
      // emit(onRequestSuccess());
    } catch (e) {
      emit(onRequestFail());
      showToast(e.toString(), duration: Toast.LENGTH_LONG);
    }
  }

  StreamSubscription? requestStream;
  Response? response;

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

  onRequestFail() {
    emit(RequestFailed());
  }

  onRequestSuccess() {
    emit(RequestSucceeded());
  }

  bool isUserLogin() => UserFirebase.isUserLogin();

  Future<bool> isRequestSent() async {
    final preference = await getPreference();
    return preference.containsKey(REQUEST_SENT_FLAG) &&
        preference.getBool(REQUEST_SENT_FLAG)!!;
  }
}
