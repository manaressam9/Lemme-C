import 'package:flutter/material.dart';

import '../../../../shared/components.dart';
import '../../../../shared/constants.dart';
import '../../../../shared/styles/colors.dart';
import '../../../../strings/strings.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class LoginScreen extends StatelessWidget {
  final _phoneNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  VolunteerRequestCubit cubit;
  VolunteerRequestStates myState;

  LoginScreen(this.cubit, this.myState);

  @override
  Widget build(BuildContext context) {
    screenWidth = getScreenWidth(context);
    screenHeight = getScreenHeight(context);
    return SingleChildScrollView(
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

  buildLoginButton(BuildContext context, VolunteerRequestCubit cubit) {
    return myState is PhoneFilteringLoadingState || myState is PhoneAlreadyExist
        ? CircularProgressIndicator(
            strokeWidth: 2,
            color: BLACK_COLOR,
          )
        : buildDefaultBtn(
            onPressed: () async {
              cubit.phone = '+2' + _phoneNumController.text;
              if (_formKey.currentState!.validate()) {
                if (await cubit.isPhoneNumberExist(sourceScreen: 1))
                  await cubit.sendPhoneOtp(0);
                else
                  showToast('This Phone is not exist!');
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
              cubit.switchRegLogin();
            },
            txt: 'account',
            context: context)
      ],
    );
  }
}
