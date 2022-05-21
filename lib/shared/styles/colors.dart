import 'package:flutter/material.dart';

const Color MAIN_COLOR = Color.fromRGBO(3,124,250,1);
const Color GREY_COLOR = Colors.grey;
const Color BLACK_COLOR = Colors.black;
const Color WHITE_COLOR = Colors.white;

const MaterialColor PRIMARY_SWATCH = MaterialColor(
  _Main_Color,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(_Main_Color),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);
const int _Main_Color = 0xFFFFFFFF;