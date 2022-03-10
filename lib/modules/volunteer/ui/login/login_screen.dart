import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/layouts/home_screen/home_screen.dart';
import 'package:object_detection/modules/volunteer/ui/register/cubit/cubit.dart';
import 'package:object_detection/modules/volunteer/ui/register/register_screen.dart';

import '../../../../shared/components.dart';
import '../../../../shared/constants.dart';
import '../../../../shared/styles/colors.dart';
import '../../../../strings/strings.dart';
import '../register/cubit/states.dart';
import '../register/phone_Verification_screen.dart';

class LoginScreen extends StatelessWidget {
  final _phoneNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  RegisterStates globalState = RegisterInitState();


  @override
  Widget build(BuildContext context) {
    screenHeight = getScreenHeight(context);
    screenWidth = getScreenWidth(context);
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          globalState = state;
        },
        builder: (context, state) {
          RegisterCubit cubit = RegisterCubit.get(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    screenWidth / 9, screenHeight / 12, screenWidth / 9, 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        LOGIN_IMG,
                        width: screenWidth / 2,
                        height: screenHeight / 8,
                      ),
                      buildVerticalSpace(height: screenHeight / 12),
                      buildTextField(context),
                      buildVerticalSpace(height: screenHeight / 20),
                      buildLoginButton(context, cubit),
                      buildVerticalSpace(height: screenHeight / 30),
                      buildRegisterTextButton(context)
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

  Widget buildTextField(BuildContext context) {
    return buildDefaultTextField(
        context: context,
        controller: _phoneNumController,
        label: PHONE_NUMBER,
        type: TextInputType.phone,
        validator: (String? value) {
          if (value == null || value.isEmpty) return 'Phone is required !';
          if (value.length != 11) return 'Invalid phone !';
          String firstPart = value.substring(0, 3);
          if ((firstPart != '010' &&
              firstPart != '011' &&
              firstPart != '012' &&
              firstPart != '015')) return 'Invalid phone !';
          return null;
        });
  }

  buildLoginButton(BuildContext context, RegisterCubit cubit) {
    return globalState is RegisterLoadingState
        ? CircularProgressIndicator(
            strokeWidth: 2,
            color: BLACK_COLOR,
          )
        : buildDefaultBtn(
            onPressed: () async {
              cubit.phone = '+2' + _phoneNumController.text;
              if (_formKey.currentState!.validate()) {
                await cubit.sendPhoneOtp(0);
                navigate(context, PhoneVerificationScreen(cubit, "LOGIN"));
              }
            },
            txt: 'Login',
            context: context);
  }

  buildRegisterTextButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Create',
          style: TextStyle(fontSize: 13, color: GREY_COLOR),
        ),
        buildTextButton(
            onPressed: () {
              navigateAndFinish(
                  context,
                  HomeScreen(
                    selectedIndex: 3,
                    loginOrReg: 'REGISTER',
                  ));
            },
            txt: 'account',
            context: context)
      ],
    );
  }
}
