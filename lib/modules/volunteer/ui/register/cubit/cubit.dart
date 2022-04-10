import 'dart:ffi';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/modules/volunteer/ui/register/cubit/states.dart';

import '../../../../../models/User.dart';
import '../../../../../shared/constants.dart';
import '../../../../../strings/strings.dart';
import '../../../../../utils/tts_utils.dart';
import '../../../data/firebase/user_firebase.dart';
import '../../../data/location/location_api.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  onVolunteerInit() {
    TTS.speak(VOLUNTEER_MOD_LABEL);
    HomeScreen.cubit.changeSelectedIndex(3);
  }

  String loginOrReg = 'REGISTER';

  void switchRegLogin() {
    loginOrReg = (loginOrReg == 'REGISTER') ? 'LOGIN' : 'REGISTER';
    emit(LoginRegSwitch());
  }

  enterNextStage(RegisterStates stageState) {
    emit(RegisterFirstStageCompletedState());
  }

  backStage(RegisterStates stageState) {
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
          onAutoVerificationTimeOut: onCodeAutoRetrievalTimeout
      );
      if (fromRegisterOrVerifyScreen != 0) //request from registerScreen
        emit(PhoneCodeResentState()); //request from phone verification screen
    } on FirebaseAuthException catch (err) {
      String errMessage = handleError(err.code);
      emit(RegisterErrorState(errMessage));
    }
  }

  Future<bool> isPhoneNumberExist() async {
    emit(PhoneFilteringLoadingState());
    bool isExist = await UserFirebase.isPhoneNumberExist(phone);
    if (isExist)
      emit(PhoneAlreadyExist());
    else
      emit(PhoneNotExist());
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

  onCodeAutoRetrievalTimeout(String verificationId){
    emit(AutoVerificationTimeOut());
  }

  onCodeSentHandler(String verificationId, int? resendToken) {
    emit(PhoneCodeSentState());
    this.verificationId = verificationId;
  }

  onVerificationFailed(FirebaseAuthException e) {
    String errMessage = handleError(e.code);
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
  onVolunteerRequest() async {
    emit(RequestLoading());
    await LocationApi.sendRealTimeLocationUpdates();
  }

  onRequestFail ()
  {
    emit(RequestFailed());
  }
  onRequestSuccess() {
    emit(RequestSucceeded());
  }
}
