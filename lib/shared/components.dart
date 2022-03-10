import 'package:flutter/material.dart';
import 'package:object_detection/shared/styles/colors.dart';

import '../strings/strings.dart';

buildVerticalSpace({double? height = 20.0}) => SizedBox(
      height: height,
    );

buildHorizontalSpace({double? width = 20.0}) => SizedBox(
      width: width,
    );

buildLogoImage({double topPadding = 10.0}) {
  return Hero(
    tag: 'logo',
    child: Padding(
      padding:  EdgeInsets.only(top: topPadding,left: 60,right: 60),
      child: Image(
        height: 200,
        image: AssetImage('$GLASSES_IMG'),
      ),
    ),
  );
}

buildDefaultTextField({
  required context,
  required TextEditingController controller,
  required String label,
  required TextInputType type,
  required String? Function(String?) validator,
  IconData? suffixIcon,
  bool isSecure = false,
  void Function()? onSuffixPressed,
  bool focusedOutlineBorder = true,
  bool enabledOutlineBorder = true,
  Color focusBorderColor = MAIN_COLOR,
  Color enabledBorderColor = MAIN_COLOR,
  Color textColor = BLACK_COLOR,
  double borderRadius = 5,
  Function(String?)? onChange,
}) {
  return TextFormField(
    obscureText: isSecure,
    keyboardType: type,
    /*   style: getTextTheme(context).bodyText1!.copyWith(
      color: textColor,
    ),*/
    cursorColor: GREY_COLOR,
    onChanged: onChange,
    decoration: InputDecoration(
      /* labelStyle: getTextTheme(context)
          .bodyText1!
          .copyWith(color: focusBorderColor, height: 1, fontSize: 13),*/
      focusedBorder: focusedOutlineBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: focusBorderColor,
                width: 2.5,
              ))
          : UnderlineInputBorder(
              borderSide: BorderSide(
              color: focusBorderColor,
              width: 1.8,
            )),
      enabledBorder: enabledOutlineBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: enabledBorderColor, width: 1.2))
          : UnderlineInputBorder(
              borderSide: BorderSide(color: enabledBorderColor, width: 1.2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: enabledBorderColor, width: 1.2)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: enabledBorderColor, width: 1.2)),
      //borders

      labelText: label,
      labelStyle:TextStyle(color: GREY_COLOR) ,
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(
                suffixIcon,
                color: MAIN_COLOR,
              ),
              onPressed: () {
                onSuffixPressed!();
              },
            )
          : null,
    ),
    validator: validator,
    controller: controller,
  );
}

buildDefaultBtn({
  required void Function()? onPressed,
  required String txt,
  required context,
  double radius = 5,
  TextStyle? textStyle,
  double width = double.infinity,
  double fontSize = 17,
}) {
  return Container(
    decoration: BoxDecoration(
        color: MAIN_COLOR, borderRadius: BorderRadius.circular(radius)
    ,  boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        blurRadius: 1,
        offset: Offset(0, 2),
      ),
    ],
    ),
    child: MaterialButton(
      minWidth: width,
      height: 50,
      highlightElevation: 20,
      disabledColor: Colors.grey,
      onPressed: onPressed,
      child: Text(txt,
          style: textStyle == null
              ? TextStyle(
                  color: WHITE_COLOR,
                  fontSize: fontSize,
                  fontFamily: LIGHT_FONT)
              : textStyle),
    ),
  );
}

buildTextButton(
    {required String txt,
    required BuildContext context,
    required void Function() onPressed,
    }) {
  return TextButton(
    onPressed: onPressed,
    child: Text(txt, style: TextStyle(color: MAIN_COLOR,fontSize: 15)),
  );
}
