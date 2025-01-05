import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:loggy/loggy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Initial {
  Initial({required this.version, required this.permissionsWereGranted});
  String version;
  bool permissionsWereGranted;
}

class SettingsRep {
  // static const _permissionGrantKey = 'perm_grant';
  static const _usedCameraIdKey = 'camera_id';
  static final SettingsRep _instance = SettingsRep._internal();
  final tag = 'settings';

  Future<Initial> init() async {
    // final prefs = await SharedPreferences.getInstance();
    // version
    var packageInfo = await PackageInfo.fromPlatform();
    return Initial(
        version: packageInfo.version,
        permissionsWereGranted: //prefs.getBool(_permissionGrantKey) ??
            false);
  }

  void setCameraUsed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usedCameraIdKey, id);
  }

  Future<String?> getCameraUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usedCameraIdKey);
  }

  // void setPermissionsGranted() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setBool(_permissionGrantKey, true);
  // }

  //
  // remove all stored values
  Future removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(_themeKey);
    // await prefs.remove(_domainKey);
    // await prefs.remove(_isDevKey);
    // await prefs.remove(_updateBranchKey);
  }

  factory SettingsRep() {
    return _instance;
  }
  SettingsRep._internal();
}
