import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color roseGold = Color(0xFFE3A8A8);
  static const Color deepBlue = Color(0xFF2E3F61);

  static const cupertinoTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF5873A8),
    scaffoldBackgroundColor: Color(0xFFF6F8FC),
    textTheme: CupertinoTextThemeData(
      navTitleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      textStyle: TextStyle(fontSize: 15, color: Color(0xFF1D2433)),
    ),
  );
}
