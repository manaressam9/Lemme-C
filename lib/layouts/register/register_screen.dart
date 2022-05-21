import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:volunteer_application/layouts/register/phone_Verification_screen.dart';

import '../../../../shared/components.dart';
import '../../../../shared/constants.dart';
import '../../shared/styles/colors.dart';
import '../../strings.dart';
import '../login/login_screen.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumController = TextEditingController();
  final _idController = TextEditingController();
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  RegisterStates globalState = RegisterInitState();

  late RegisterCubit cubit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(

        listener: (context, state) {
          globalState = state;
          if (globalState is PhoneCodeSentState)
            navigate(context, PhoneVerificationScreen(cubit, 'REGISTER'));
          else if (globalState is RegisterErrorState)
             showToast((globalState as RegisterErrorState).errorMsg);
        },
        builder: (context, state) {
          cubit = RegisterCubit.get(context);
          screenHeight = getScreenHeight(context);
          screenWidth = getScreenWidth(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Volunteering',
              ),
              titleSpacing: 20,
              leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Image(
                  image: AssetImage(CHECKHAND_IMG),
                ),
              ),
              leadingWidth: 50,

            ),
            body:  cubit.loginOrReg == 'REGISTER'? SingleChildScrollView(
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
                      buildTextFieldsLayout(context, cubit),
                      buildVerticalSpace(height: screenHeight / 30),
                      buildHaveAnAccount(context)
                    ],
                  ),
                ),
              ),
            ) : SingleChildScrollView(
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
 //REGISTER
  buildTextFieldsLayout(context, RegisterCubit cubit) {
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
        globalState is PhoneFilteringLoadingState ||
        globalState is PhoneNotExist || globalState is PhoneVerificationLoading
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
               // if (!await cubit.isPhoneNumberExist())
                  await cubit.sendPhoneOtp(0);
                //else
                 // showToast('This Phone is already exist!');
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
        const Text(
          'Already have an',
          style: TextStyle(fontSize: 13, color: GREY_COLOR),
        ),
        buildTextButton(
            onPressed: () {
            /*  navigateAndFinish(
                  context,
                  HomeScreen(
                    selectedIndex: 3,
                    loginOrReg: 'LOGIN',
                  ));*/
              cubit.switchRegLogin();

            },
            txt: 'account?',
            context: context)
      ],
    );
  }

  //LOGIN
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
    return globalState is PhoneFilteringLoadingState ||
        globalState is PhoneAlreadyExist ||
        globalState is PhoneVerificationLoading
        ? const CircularProgressIndicator(
      strokeWidth: 2,
      color: BLACK_COLOR,
    )
        : buildDefaultBtn(
        onPressed: () async {
          cubit.phone = '+2' + _phoneNumController.text;
          if (_formKey.currentState!.validate()) {
            if (await cubit.isPhoneNumberExist())
              await cubit.sendPhoneOtp(0);
            else {
              showToast('This Phone is not exist!');
            }
          }
        },
        txt: 'Login',
        context: context);
  }

  buildRegisterTextButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
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
