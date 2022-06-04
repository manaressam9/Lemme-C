import 'package:flutter/material.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/cubit/cubit.dart';
import 'package:object_detection/shared/constants.dart';

import '../../../../shared/components.dart';
import '../../../../shared/styles/colors.dart';
import '../../../../strings/strings.dart';
import 'cubit/states.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumController = TextEditingController();
  final _idController = TextEditingController();
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  VolunteerRequestCubit cubit;
  VolunteerRequestStates myState;
  RegisterScreen(this.cubit,this.myState);

  @override
  Widget build(BuildContext context) {
    screenWidth = getScreenWidth(context);
    screenHeight = getScreenHeight(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            screenWidth / 9, screenHeight / 16, screenWidth / 9, 10),
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
              buildTextFieldsLayout(context),
              buildVerticalSpace(height: screenHeight / 30),
              buildHaveAnAccount(context)
            ],
          ),
        ),
      ),
    );
  }

  buildTextFieldsLayout(context) {
    return Column(
      children: [
        buildDefaultTextField(
            context: context,
            controller: _fullNameController,
            label: FULL_NAME,
            type: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Name is required!';
              return null;
            }),
        buildVerticalSpace(height: screenHeight / 25),
        buildDefaultTextField(
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
            }),
        buildVerticalSpace(height: screenHeight / 25),
        buildDefaultTextField(
          context: context,
          controller: _idController,
          label: ID,
          type: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'ID is required!';
            if (value.length != 14) return 'Invalid ID!';
            return null;
          },
          suffixIcon: cubit.idSuffixIcon,
          isSecure: cubit.idSecure,
          onSuffixPressed: cubit.changeIDVisibility,
        ),
        buildVerticalSpace(height: screenHeight / 25),
        myState is PhoneFilteringLoadingState ||
                myState is PhoneNotExist ||
                myState is PhoneVerificationLoading
            ? CircularProgressIndicator(
                strokeWidth: 2,
                color: BLACK_COLOR,
              )
            : buildDefaultBtn(
                onPressed: () async {
                  cubit.phone = '+2' + _phoneNumController.text;
                  cubit.nationalId = _idController.text;
                  cubit.fullName = _fullNameController.text;
                  if (_formKey.currentState!.validate()) {
                    if (!await cubit.isPhoneNumberExist(sourceScreen: 0))
                      await cubit.sendPhoneOtp(0);
                    else
                      showToast('This Phone is already exist!');
                  }
                },
                txt: 'Sign up',
                context: context),
      ],
    );
  }
  Widget buildHaveAnAccount(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an',
          style: TextStyle(fontSize: 13, color: GREY_COLOR),
        ),
        buildTextButton(
            onPressed: () {
              cubit.switchRegLogin();
              ;
            },
            txt: 'account?',
            context: context)
      ],
    );
  }
}
