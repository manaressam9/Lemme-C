import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:volunteer_application/layouts/RequestsScreen/RequestsScreen.dart';

import '../../../../shared/constants.dart';
import '../../../../shared/styles/colors.dart';
import '../../shared/components.dart';
import '../../strings.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class PhoneVerificationScreen extends StatelessWidget {
  final RegisterCubit _cubit;
  final String previousScreenName;

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  String smsCode = '';
  TextEditingController pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PhoneVerificationScreen(this._cubit, this.previousScreenName);

  @override
  Widget build(BuildContext context) {
    screenHeight = getScreenHeight(context);
    screenWidth = getScreenWidth(context);

    return BlocProvider(
      create: (BuildContext context) => _cubit,
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          handleState(context, state);
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: WHITE_COLOR,
            appBar: AppBar(
              title: Text(
                'Verify phone',
                style: TextStyle(color: BLACK_COLOR, fontFamily: LIGHT_FONT),
              ),
              titleSpacing: 10,
              backgroundColor: WHITE_COLOR,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black54,
                ),
              ),
              elevation: 0.5,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight / 20,
                            left: screenWidth / 4,
                            right: screenWidth / 4),
                        child: Image(
                          image: AssetImage(PHONE_MSG_IMG),
                        ),
                      ),
                      buildVerticalSpace(height: screenHeight / 15),
                      const Text(
                        'OTP Verification',
                        style: TextStyle(color: BLACK_COLOR, fontSize: 17),
                      ),
                      buildVerticalSpace(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Enter the OTP sent to ',
                            style: TextStyle(
                              color: GREY_COLOR,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${_cubit.phone}',
                            style: const TextStyle(
                              color: BLACK_COLOR,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      buildVerticalSpace(height: screenHeight / 12),
                      PinCodeTextField(
                        length: 6,
                        appContext: context,
                        controller: pinController,
                        onChanged: (code) {
                          _cubit.smsCode = code;
                        },
                        validator: (String? code) {
                          if (code == null || code.length != 6)
                            return 'OTP is required';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        textStyle:
                            TextStyle(fontSize: 17, fontFamily: LIGHT_FONT),
                        pinTheme: PinTheme(
                            borderWidth: 1,
                            fieldWidth: 30,
                            activeColor: GREY_COLOR,
                            inactiveColor: GREY_COLOR),
                      ),
                      buildVerticalSpace(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t receive the OTP ? ',
                            style: TextStyle(
                              color: GREY_COLOR,
                              fontSize: 13,
                            ),
                          ),
                          buildTextButton(
                            onPressed: () {
                              _cubit.sendPhoneOtp(1);
                            },
                            txt: 'RESEND OTP',
                            context: context,
                          )
                        ],
                      ),
                      buildVerticalSpace(height: 15),
                      if (state is! AutoVerificationTimeOut)
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BLACK_COLOR,
                        ),
                      buildVerticalSpace(height: 15),
                      state is PhoneVerificationLoading
                          ? CircularProgressIndicator(
                              strokeWidth: 2,
                              color: BLACK_COLOR,
                            )
                          : buildDefaultBtn(
                              onPressed: () {
                                if (_formKey.currentState!.validate())
                                  previousScreenName == 'LOGIN'
                                      ? _cubit.logIn()
                                      : _cubit.signUp();
                              },
                              txt: 'VERIFY',
                              context: context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void handleState(BuildContext context, RegisterStates state) {
    if (state is PhoneAutoVerification) {
      pinController.text = _cubit.smsCode;
      showToast('auto verification : ${_cubit.smsCode}');
    } else if (state is PhoneCodeResentState)
      showToast('OTP is resent successfully');
    else if (state is VerificationSuccessState) {
      navigateAndFinish(context, RequestsScreen());
      showToast('Verified Successfully');
    } else if (state is RegisterErrorState) {
      {
        showToast(state.errorMsg);
      }
    }
  }
}
