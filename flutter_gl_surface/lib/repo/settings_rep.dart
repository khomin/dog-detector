import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
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
  static const _showCaptureKey = 'show_area';
  static const _captureMinAreaKey = 'capt_min_area';
  static const _captIntValSecKey = 'capt_intval_sec';
  static const _soundUsedKey = 'soundUsedKey';
  static const _packetUsedKey = 'packetUsedKey';
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

  Future<int> getCaptureIntervalSec() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_captIntValSecKey) ?? Constants.minCaptIntvalDefault;
  }

  void setCaptureIntervalSec(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_captIntValSecKey, v);
  }

  Future<int> getCaptureMinArea() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_captureMinAreaKey) ?? Constants.minAreaDefault;
  }

  void setCaptureMinArea(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_captureMinAreaKey, v);
  }

  Future<bool> getCaptureShowArea() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showCaptureKey) ?? true;
  }

  void setCaptureShowArea(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCaptureKey, v);
  }

  Future<Sound?> getSoundUsed() async {
    final prefs = await SharedPreferences.getInstance();
    var v = prefs.getString(_soundUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Sound(name: mapJson['name'], uri: mapJson['uri']);
      } catch (_) {}
    }
    return null;
  }

  void setSoundUsed(Sound? sound) async {
    final prefs = await SharedPreferences.getInstance();
    if (sound != null) {
      var map = {'name': sound.name, 'uri': sound.uri};
      var mapJson = jsonEncode(map);
      await prefs.setString(_soundUsedKey, mapJson);
    } else {
      await prefs.remove(_soundUsedKey);
    }
  }

  Future<Packet?> getPacketUriUsed() async {
    final prefs = await SharedPreferences.getInstance();
    var v = prefs.getString(_packetUsedKey);
    if (v != null) {
      try {
        var mapJson = jsonDecode(v);
        return Packet(
            uri: mapJson['uri'], tcp: mapJson['tcp'], udp: mapJson['udp']);
      } catch (_) {}
    }
    return null;
  }

  Future setPacketUri(Packet? packet) async {
    final prefs = await SharedPreferences.getInstance();
    if (packet != null) {
      var map = {'uri': packet.uri, 'tcp': packet.tcp, 'udp': packet.udp};
      var mapJson = jsonEncode(map);
      await prefs.setString(_packetUsedKey, mapJson);
    } else {
      await prefs.remove(_packetUsedKey);
    }
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
