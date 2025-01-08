import 'package:flutter/material.dart';

class Constants {
  static final Constants _instance = Constants._internal();

  static const appName = "VocaByte";
  static const localFolderName = 'vocabyte';

  static const colorBar = Color.fromARGB(255, 213, 212, 232);
  static const colorCard = Colors.white;
  static const colorBgUnderCard = Color(0xfff1f2f4);
  static const colorTextAccent = Colors.black;
  static const colorTextSecond = Color(0x70515155);

  static const colorPrimary = Color.fromARGB(255, 139, 135, 219);
  static const colorSecondary = Color.fromARGB(255, 170, 167, 225);

  static const defaultCamera = 'Back';

  static const duration = Duration(milliseconds: 200);
  static const durationPanel = Duration(milliseconds: 100);

  static int minAreaDefault = 2000;
  static int minCaptIntvalDefault = 1;

  // static const double learnCountForBreak = 20;
  // static const int reapedToLeanDefault = 10;
  // static const int goalDefault = 20;

  // static const isDev = kDebugMode;
  // static const isMock = false;
  // static const minWindowSize = Size(200, 300);

  // static const shadowDown = Offset(0, 5);
  // static const shadowUp = Offset(0, -5);
  // static const shadowUpLight = Offset(0, -1);

  // static const double dialogHeaderHeight = 30;
  // static const double dialogHeaderMiddle = 40;
  // static const double dialogHeaderLargeHeight = 56;

  // // dialogs
  // static const dialogHeadertFontSize = 15.0;
  // static const dialogHeaderFontWeight = FontWeight.w400;
  // static const dialogFontSize = 14.0;
  // static const dialogFontWeight = FontWeight.w200;

  // static const buttonHeight = 45.0;

  // static const animDurationFast = Duration(milliseconds: 50);
  // static const animDurationMid = Duration(milliseconds: 200);
  // static const animDurationMedium = Duration(milliseconds: 300);

  factory Constants() {
    return _instance;
  }

  Constants._internal();
}
